# Author::    Ondřej Ezr  (mailto:oezr@msp.justice.cz)
# Copyright:: Copyright (c) 2018 Ministry of Justice
# License::   Distributes under license Open Source Licence pro Veřejnou Správu a Neziskový Sektor v.1

module AzaharaSchemaCurrency
  class CurrencyAttribute < AzaharaSchema::Attribute

    def initialize(model, name, type='currency', **options)
      super(model, name, type)
      @options = options
    end

    def currency_code_col
      @options[:currency_code_method] || 'currency_code'
    end

    def currency_code(entity)
      entity.try(currency_code_col)
    end

    def value(record)
      val = super(record)
      val = BigDecimal.new( val.to_s ) unless val.is_a?(BigDecimal)
      val
    end

  end
end
