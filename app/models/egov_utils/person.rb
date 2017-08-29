module EgovUtils
  class Person < ApplicationRecord

    def fullname
      firstname.to_s + ' ' + lastname.to_s
    end

  end
end
