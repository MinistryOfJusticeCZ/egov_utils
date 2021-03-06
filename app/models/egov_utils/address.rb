module EgovUtils
  class Address < ApplicationRecord

    # before_safe :identify_address , if: :changed?

    validates :street, :city, length: 2..255
    validates :postcode, numericality: { only_integer: true }
    with_options if: :in_czech_republic? do
      validates :district, inclusion: { in: :district_names }
      validates :region, inclusion: { in: :region_names }
    end
    with_options unless: :in_czech_republic? do
      validates :district, inclusion: { in: :district_names }, allow_nil: true
      validates :region, inclusion: { in: :region_names }, allow_nil: true
    end
    validates :country, inclusion: { in: :country_ids }, allow_nil: true

    District = Struct.new(:id, :name, :region_id)
    Region = Struct.new(:id, :name)
    Country = Struct.new(:iso_id, :code2, :code3, :name)

    CZ_ISO_CODE = '203'

    def self.countries
      return @countries if @countries
      require 'csv'
      @countries = []
      CSV.foreach(EgovUtils::Engine.root.join('config', 'countries.csv'), col_sep: ';', headers: true) do |row|
        @countries << Country.new( row[0], row[1], row[2], row[3]) if row[1]
      end
      @countries
    end

    def self.districts
      return @districts if @districts
      require 'csv'
      @districts = []
      CSV.foreach(EgovUtils::Engine.root.join('config', 'okres.csv'), col_sep: ';', headers: true) do |row|
        @districts << District.new( row[0].to_i, row[1], row[2].to_i) if row[1]
      end
      @districts
    end

    def self.regions
      return @regions if @regions
      require 'csv'
      @regions = []
      CSV.foreach(EgovUtils::Engine.root.join('config', 'kraj.csv'), col_sep: ';', headers: true) do |row|
        @regions << Region.new( row[0].to_i, row[1]) if row[1]
      end
      @regions
    end

    def self.region_for_district(district_name)
      district = districts.detect{|d| d[:name] == district_name }
      regions.detect{|r| r[:id] == district[:region_id] } if district
    end

    def in_czech_republic?
      country == CZ_ISO_CODE || country.nil?
    end

    def district_names
      self.class.districts.collect{|r| r[:name]}
    end
    def region_names
      self.class.regions.collect{|r| r[:name]}
    end
    def country_ids
      self.class.countries.collect{|r| r[:iso_id]}
    end


    def district=(value)
      self.region = self.class.region_for_district(value).try(:[], :name)
      super
    end

    def number
      if !house_number.blank? && !orientation_number.blank?
        "#{house_number}/#{orientation_number}"
      else
        house_number.presence || orientation_number.presence
      end
    end

    def full_address
      to_s
    end

    def to_s
      "#{street} #{number}, #{postcode} #{city}"
    end

    def prepare_egon_message(message)
      message.obec_nazev = city.presence
      message.cast_obce_nazev = city_part.presence
      message.ulice_nazev = street.presence
      message.posta_kod = postcode.presence
      message.cislo_domovni = house_number.presence
      message.cislo_orientacni = orientation_number.presence
    end

    def from_egon_info(message)
      self.egov_identifier = message[:adresni_misto_kod]
      self.district = message[:okres_nazev]
      self.city = message[:obec_nazev]
      self.city_part = message[:cast_obce_nazev]
      self.street = message[:ulice_nazev]
      self.postcode = message[:posta_kod]
      self.house_number = message[:cislo_domovni]
      self.orientation_number = message[:cislo_orientacni]+(message[:cislo_orientacni_pismeno] || '')
    end

  end
end
