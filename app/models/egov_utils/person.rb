module EgovUtils
  class Person < ApplicationRecord

    validates :firstname, :lastname, :birth_date, presence: true
    validates :birth_date, uniqueness: { scope: [:firstname, :lastname] }, birthday: true

    def fullname
      firstname.to_s + ' ' + lastname.to_s
    end

  end
end
