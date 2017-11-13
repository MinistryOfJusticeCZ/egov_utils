require_dependency 'egov_utils/auth_source'
module EgovUtils
  class Group < Principal
    validates :name, presence: true, uniqueness: true
    validates :ldap_uid, uniqueness: true, allow_nil: true

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
      super || auth_source.send(:get_group_dn, sid: ldap_uid)
    end

  end
end
