require_dependency 'egov_utils/auth_source'
require 'request_store_rails'

module EgovUtils
  class User < Principal
    has_secure_password validations: false

    serialize :roles, Array

    validates :login, uniqueness: true

    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }

    def self.authenticate(login, password, active_only=true)
      login = login.to_s
      password = password.to_s

      # Make sure no one can sign in with an empty login or password
      return nil if login.empty? || password.empty?
      user = find_by(login: login) || find_by(mail: login)
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
    end

    def all_roles
      all_role_names.map{|rn| EgovUtils::UserUtils::Role.find(rn) }.compact.collect{|cls| cls.new }
    end

    def groups
      ldap_groups || []
    end

    def ldap_dn
      @ldap_dn = auth_source.send(:get_user_dn, login)[:dn]
    end

    def ldap_groups
      if provider.present?
        group_ids = Rails.cache.read("#{cache_key}/ldap_group_ids", expires_in: 30.minutes)
        if group_ids
          groups = EgovUtils::Group.where(id: group_ids).to_a
        else
          groups = EgovUtils::Group.where(provider: provider).to_a.select{|g| auth_source.member?(ldap_dn, g.external_uid) }
          Rails.cache.write("#{cache_key}/ldap_group_ids", groups.collect(&:id), expires_in: 30.minutes)
        end
        groups
      end
    end

  end
end
