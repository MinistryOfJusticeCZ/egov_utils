module EgovUtils
  class FullAddress < AzaharaSchema::Attribute

    def arel_field
      Arel::Nodes::NamedFunction.new 'CONCAT', [EgovUtils::Address.arel_table[:city], Arel::Nodes::SqlLiteral.new('\' \'') , EgovUtils::Address.arel_table[:street]]
    end

    def build_json_options!(options)
      options[:methods] ||= []
      options[:methods] << 'full_address'
      options
    end

  end
end
