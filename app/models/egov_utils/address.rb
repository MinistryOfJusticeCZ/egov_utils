module EgovUtils
  class Address < ApplicationRecord

    # before_safe :identify_address , if: :changed?

    validates :street, :city, length: 3..255
    validates :postcode, numericality: { only_integer: true }

    def self.districts
      return @districts if @districts
      require 'csv'
      @districts = []
      CSV.foreach(EgovUtils::Engine.root.join('config', 'okres.csv'), col_sep: ';', headers: true) do |row|
        @districts << row[1] if row[1]
      end
      @districts
    end

    def self.regions
      return @regions if @regions
      require 'csv'
      @regions = []
      CSV.foreach(EgovUtils::Engine.root.join('config', 'kraj.csv'), col_sep: ';', headers: true) do |row|
        @regions << row[1] if row[1]
      end
      @regions
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
