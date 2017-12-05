module EgovUtils
  class Principal < ApplicationRecord
    self.abstract_class = true

    serialize :roles, Array

    def reload(*attrs)
      @auth_source = nil
      super
    end

    def has_role?(role)
      roles.include?(role)
    end

    def auth_source
      @auth_source ||= EgovUtils::AuthSource.new(provider) if provider.present?
    end

    def ldap?
      !!auth_source
    end

    def ldap_dn
      raise NotImplementedError
    end

    def ldap_domain
      ldap? && ldap_dn.scan(/dc=([^,]*)/i).flatten.join('.')
    end

    def organization_by_domain(ldap_domain=self.ldap_domain)
      @organization_by_domain ||= EgovUtils::Organization.where(domain: ldap_domain).first if ldap_domain
    end

    def organization_key
      organization_by_domain.try(:key)
    end

    def organization_id(organization_key=self.organization_key)
      EgovUtils::Organization.find_by_key(organization_key).try(:id)
    end

    def organization_with_suborganizations_keys(organization_key=self.organization_key)
      return [] unless organization_key
      Rails.cache.fetch("organizations/#{organization_key}/org_with_suborgs_keys") do
        [organization_key] + ( organization_key && EgovUtils::Organization.where(superior_id: organization_id(organization_key)).collect(&:key) || [] )
      end
    end
  end
end
