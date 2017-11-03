module EgovUtils
  class Person < ApplicationRecord

    belongs_to :residence, class_name: 'EgovUtils::Address'

    validates :firstname, :lastname, :birth_date, presence: true
    validates :birth_date, uniqueness: { scope: [:firstname, :lastname] }, birthday: true

    accepts_nested_attributes_for :residence

    def fullname
      firstname.to_s + ' ' + lastname.to_s
    end

  end
end
