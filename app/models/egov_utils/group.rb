require_dependency 'egov_utils/auth_source'
module EgovUtils
  class Group < Principal
    validates :name, presence: true, uniqueness: true

    def members

    end

    def ldap_members
      @ldap_members ||= if provider.present?
                          auth_source.group_members(ldap_uid)
                        else
                          []
                        end
    end

    def ldap_member?(user)
      ldap_members.detect{|mem| mem[:login] == user.login }
    end

  end
end
