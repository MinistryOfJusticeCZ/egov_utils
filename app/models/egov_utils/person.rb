module EgovUtils
  class Person < ApplicationRecord

    belongs_to :residence, class_name: 'EgovUtils::Address', optional: true
    has_one :natural_person, dependent: :destroy
    has_one :legal_person, dependent: :destroy

    enum person_type: { natural: 1, legal: 16 }

    validates :person_entity, presence: true

    accepts_nested_attributes_for :residence, :natural_person, :legal_person

    delegate :fullname, :fullname=, to: :person_entity

    def person_entity
      case person_type
      when 'natural'
        natural_person
      when 'legal'
        legal_person
      end
    end

    def to_s
      person_entity.to_s
    end

  end
end
