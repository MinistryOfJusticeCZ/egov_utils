module EgovUtils
  class Fullname < AzaharaSchema::Attribute

    def arel_field
      Arel::Nodes::NamedFunction.new 'CONCAT', [EgovUtils::Person.arel_table[:lastname], Arel::Nodes::SqlLiteral.new('\' \'') , EgovUtils::Person.arel_table[:firstname]]
    end

    def build_json_options!(options)
      options[:methods] ||= []
      options[:methods] << 'fullname'
      options
    end

  end
end
