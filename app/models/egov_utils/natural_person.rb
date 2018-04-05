module EgovUtils
  class NaturalPerson < AbstractPerson

    belongs_to :person, class_name: 'EgovUtils::Person'

    validates :firstname, :lastname, :birth_date, presence: true
    validates :birth_date, uniqueness: { scope: [:firstname, :lastname] }, birthday: true

    def fullname
      firstname.to_s + ' ' + lastname.to_s
    end

    def to_s
      "#{fullname} (#{I18n.t(:text_born_on_at, place: birth_place, date: I18n.l(birth_date.to_date))})"
    end

  end
end
