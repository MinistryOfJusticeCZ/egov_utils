module EgovUtils
  class Organization < Love

    def self.find_by_key(key)
      where(key: key).first
    end

    def self.courts(organization_keys=nil)
      filters = {category_abbrev: ['OS','KS']}
      filters.merge!(key: organization_keys) if organization_keys.present?
      all(params: {f: filters, sort: {'0' => {path: 'category_abbrev'} }})
    end

  end
end
