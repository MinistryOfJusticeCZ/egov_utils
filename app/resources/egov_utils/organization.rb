module EgovUtils
  class OrganizationMock < LoveMock
    def self.all(*attrs)
      [
        new(id: 1, name: 'Městský soud 1', key: '104000', category_abbrev: 'MS' ),
        new(id: 2, name: 'Krajský soud 1', key: '204000', category_abbrev: 'KS' ),
        new(id: 3, name: 'Krajský soud 2', key: '205000', category_abbrev: 'KS' ),
        new(id: 13, name: 'Okresní soud 1', key: '204001', category_abbrev: 'OS' ),
        new(id: 14, name: 'Okresní soud v Chomutově', key: '205030', category_abbrev: 'OS' )
      ]
    end

    def self.find_by_key(key)
      all.detect{ |o| o.key == key }
    end

    def self.courts(organization_keys=nil)
      all.select do |o|
        %w{OS KS MS}.include?(o.category_abbrev) &&
          (organization_keys.nil? || organization_keys.include?(o.key))
      end
    end

    def self.region_courts(branches=false)
      all.select{ |o| %w{KS MS}.include?(o.category_abbrev) }
    end

    def branch_of_id; end
  end

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
