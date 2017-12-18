module EgovUtils
  class Organization < Love

    def self.find_by_key(key)
      where(key: key).first
    end

    def self.courts(organization_keys=nil)
      filters = {category_abbrev: ['OS','KS', 'MS']}
      filters.merge!(key: organization_keys) if organization_keys.present?
      all(params: {f: filters, sort: {'0' => {path: 'category_abbrev'} }})
    end

    def self.region_courts(branches=false)
      all(params: {f: {category_abbrev: ['KS','MS'], branch_of_id: [nil]}, sort: {'0' => {path: 'name'} }})
    end

    def self.district_courts(superior_ids=nil)
      f = superior_ids ? {superior_id: superior_ids} : {}
      all(params: {f: f.merge({category_abbrev: '=|OS'}), sort: {'0' => {path: 'name'} }})
    end

  end
end
