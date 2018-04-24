require 'money'

require 'azahara_schema_currency/currency_format'
require 'azahara_schema_currency/currency_attribute'

require 'azahara_schema_currency/attribute_formatter_patch'
AzaharaSchema::AttributeFormatter.__send__('prepend', AzaharaSchemaCurrency::AttributeFormatterPatch)

require 'azahara_schema_currency/association_attribute_patch'
AzaharaSchema::AssociationAttribute.__send__('prepend', AzaharaSchemaCurrency::AssociationAttributePatch)
