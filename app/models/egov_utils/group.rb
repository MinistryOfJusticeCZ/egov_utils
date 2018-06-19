require_dependency 'egov_utils/auth_source'
module EgovUtils
  class Group < Principal

    has_and_belongs_to_many :users

    validates :name, presence: true, uniqueness: true
    validates :ldap_uid, uniqueness: true, allow_nil: true

    def self.organizations_by_domains(domains)
      EgovUtils::Organization.where(domain: domains)
    end

    def allow_member_assign?
      provider.nil?
    end

    def members
      if ldap?
        EgovUtils::User.where(login: ldap_members.collect{|m| m[:login] })
      else
        users
      end
    end

    def ldap_members
      if provider.present?
        Rails.cache.fetch("#{cache_key}/ldap_members", expires_in: 2.hours) do
          auth_source.group_members(ldap_dn)
        end
      else
        []
      end
    end

    def ldap_member?(user)
      ldap_members.detect{|mem| mem[:login] == user.login }
    end

    def external_uid
      super || ( ldap? && ldap_uid && auth_source.send(:get_group_dn, sid: ldap_uid) )
    end

    def ldap_dn
      ldap? && external_uid
    end

  end
end
