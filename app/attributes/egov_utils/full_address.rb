module EgovUtils
  class FullAddress < AzaharaSchema::Attribute

    def initialize
      super(EgovUtils::Address, 'full_address', 'string')
    end

    def arel_field
      Arel::Nodes::NamedFunction.new 'CONCAT', [EgovUtils::Address.arel_table[:city], Arel::Nodes::SqlLiteral.new('\' \'') , EgovUtils::Address.arel_table[:street]]
    end

    def path
      'full_address'
    end

  end
end
