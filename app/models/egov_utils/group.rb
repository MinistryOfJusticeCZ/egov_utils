require_dependency 'egov_utils/auth_source'
module EgovUtils
  class Group < Principal
    validates :name, presence: true, uniqueness: true
    validates :ldap_uid, uniqueness: true, allow_nil: true

    def self.organizations_by_domains(domains)
      EgovUtils::Organization.where(domain: domains)
    end

    def members

    end

    def ldap_members
      Rails.cache.fetch("#{cache_key}/ldap_members", expires_in: 2.hours) do
        if provider.present?
          auth_source.group_members(ldap_uid)
        else
          []
        end
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
