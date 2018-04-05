module EgovUtils
  class LegalForm < Love

    def self.find_by_key(key)
      where(key: key).first
    end

  end
end
