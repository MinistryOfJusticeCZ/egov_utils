require_dependency 'egov_utils/auth_source'
require 'request_store_rails'

module EgovUtils
  class User < Principal

    has_and_belongs_to_many :groups

    serialize :roles, Array

    has_secure_password validations: false

    validates_confirmation_of :password, if: lambda { |m| m.password.present? }
    validates_presence_of     :password, on: :create, unless: :provider?
    validates_presence_of     :password_confirmation, if: lambda { |m| m.password.present? }
    validates                 :login, uniqueness: true

    before_validation :generate_confirmation_code, unless: :provider?
    before_validation :generate_password_if_needed

    scope :active,   -> { where(active: true) }
    scope :inactive, -> { where(active: false) }

    scope :in_group, ->(group){
      group_id = group.is_a?(EgovUtils::Group) ? group.id : group.to_i
      at = Arel::Table.new('egov_utils_groups_users', as: 'gu')
      where( arel_table[:id].in( at.project(at[:user_id]).where(at[:group_id].eq(group_id)) ) )
    }
    scope :not_in_group, ->(group){
      group_id = group.is_a?(EgovUtils::Group) ? group.id : group.to_i
      at = Arel::Table.new('egov_utils_groups_users', as: 'gu')
      where(arel_table[:id].not_in( at.project(at[:user_id]).where(at[:group_id].eq(group_id)) ))
    }

    cattr_accessor :default_role
    self.default_role = nil

    attribute :generate_password, :boolean, default: false

    def self.authenticate(login, password, active_only=true)
      login = login.to_s
      password = password.to_s

      # Make sure no one can sign in with an empty login or password
      return nil if login.empty? || password.empty?

      # Fail over to case-insensitive if none was found
      user = find_by(login: login) || where( arel_table[:login].lower.eq(login.downcase) ).first

      if user
        # user is already in local database
        return nil unless user.password_check?(password)
        return nil if active_only && !user.active?
      else
        # user is not yet registered, try to authenticate with available sources
        attrs = EgovUtils::AuthSource.authenticate(login, password)
        if attrs
          user = new(attrs.merge(active: true))
          if user.ldap_register_allowed? && user.save
            user.reload
            logger.info("User '#{user.login}' created from external auth source: #{user.provider}") if logger && user.auth_source
          end
        end
      end
      user.update_column(:last_login_at, Time.now) if user && !user.new_record? && user.active?
      user
    end

    def self.anonymous
      self.new
    end

    def self.current=(user)
      RequestLocals.store[:current_user] = user || anonymous
    end

    def self.current
      RequestLocals.fetch(:current_user) { User.anonymous }
    end

    def to_s
      fullname
    end

    def roles
      logged? ? super : ['anonymous']
    end

    def ldap_register_allowed?
      auth_source && auth_source.register_members_only? && ldap_groups.any?
    end

    def password_check?(password)
      if provider.present?
        auth_source.authenticate(login, password)
      else
        authenticate(password)
      end
    end

    def password_change_possible?
      !provider.present?
    end

    def logged?
      persisted?
    end

    def locked?
      false
    end

    def fullname
      "#{firstname} #{lastname}"
    end

    def admin?
      has_role?('admin')
    end

    def has_role?(role_name)
      all_role_names.include?(role_name)
    end

    def all_role_names
      @all_role_names ||= Rails.cache.fetch("#{cache_key}/all_role_names", expires_in: 1.hours) do
                            groups.collect{|g| g.roles}.reduce([], :concat) + roles
                          end
      @all_role_names << self.class.default_role if self.class.default_role && !@all_role_names.any?
      @all_role_names
    end

    def all_roles
      all_role_names.map{|rn| EgovUtils::UserUtils::Role.find(rn) }.compact.collect{|cls| cls.new }
    end

    def groups
      super.to_a.concat( Array.wrap(ldap_groups) )
    end

    def ldap_dn
      @ldap_dn ||= ( dn = auth_source.send(:get_user_dn, login) ) && dn[:dn]
    end

    def ldap_groups
      if provider.present?
        group_ids = persisted? && Rails.cache.read("#{cache_key}/ldap_group_ids", expires_in: 30.minutes)
        if group_ids
          groups = EgovUtils::Group.where(id: group_ids).to_a
        else
          groups = EgovUtils::Group.where(provider: provider).to_a.select{|g| auth_source.member?(ldap_dn, g.external_uid) }
          Rails.cache.write("#{cache_key}/ldap_group_ids", groups.collect(&:id), expires_in: 30.minutes) if persisted?
        end
        groups
      end
    end

    def must_change_password?
      (super || password_expired?) && !provider?
    end

    def password_expired?
      false
    end

    def generate_reset_password_token
      self.confirmation_code = nil
      generate_confirmation_code
    end

    private

      def generate_confirmation_code
        self.confirmation_code ||= SecureRandom.hex
      end

      def generate_password_if_needed
        if generate_password? && !provider?
          set_random_password(10)
        end
      end

      def set_random_password(length=40)
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        chars -= %w(0 O 1 l)
        password = ''
        length.times {|i| password << chars[SecureRandom.random_number(chars.size)] }
        self.password = password
        self.password_confirmation = password
        self.must_change_password = true
        self.password_changed_at = Time.now
        self
      end

  end
end
