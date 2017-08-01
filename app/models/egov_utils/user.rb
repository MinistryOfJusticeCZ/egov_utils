require_dependency 'egov_utils/auth_source'

module EgovUtils
  class User < ApplicationRecord
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
      # else
      #   # user is not yet registered, try to authenticate with available sources
      #   attrs = AccreditedEntities::AuthSource.authenticate(login, password)
      #   if attrs
      #     user = new(attrs)
      #     user.login = login
      #     if user.save
      #       user.reload
      #       logger.info("User '#{user.login}' created from external auth source: #{user.auth_source.type} - #{user.auth_source.name}") if logger && user.auth_source
      #     end
      #   end
      end
      user.update_column(:last_login_at, Time.now) if user && !user.new_record? && user.active?
      user
    rescue => err
      raise err
    end

    def self.anonymous
      self.new
    end

    def self.current=(user)
      RequestStore.store[:current_user] = user || anonymous
    end

    def self.current
      RequestStore.store[:current_user]
    end

    def password_check?(password)
      if provider
        EgovUtils::AuthSource.new(provider).authenticate(login, password)
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
      roles.include?(:admin)
    end

  end
end
