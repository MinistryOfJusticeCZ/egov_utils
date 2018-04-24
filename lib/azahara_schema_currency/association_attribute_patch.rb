module AzaharaSchemaCurrency
  module AssociationAttributePatch

    def currency_code_col
      association.name.to_s+'-'+attribute.try(:currency_code_col).to_s
    end

  end
end
