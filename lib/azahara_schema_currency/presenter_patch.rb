module AzaharaSchemaCurrency
  module PresenterPatch

    def format_value_html(attribute, unformated_value, **options)
      case attribute.type
      when 'currency'
        Money.from_amount(unformated_value, options[:currency_code].to_s.upcase.presence).format
      else
        super
      end
    end


    def formatting_options(attribute, entity)
      case attribute.type
      when 'currency'
        {currency_code: attribute.currency_code(entity).to_s}
      else
        super
      end
    end

  end
end
