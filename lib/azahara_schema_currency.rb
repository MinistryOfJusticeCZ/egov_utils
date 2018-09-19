require 'money'

require 'azahara_schema_currency/currency_format'
require 'azahara_schema_currency/currency_attribute'

require 'azahara_schema_currency/presenter_patch'
AzaharaSchema::Presenter.__send__('prepend', AzaharaSchemaCurrency::PresenterPatch)

require 'azahara_schema_currency/association_attribute_patch'
AzaharaSchema::AssociationAttribute.__send__('prepend', AzaharaSchemaCurrency::AssociationAttributePatch)
require 'azahara_schema_currency/aggregation_attribute_patch'
AzaharaSchema::AggregationAttribute.__send__('prepend', AzaharaSchemaCurrency::AggregationAttributePatch)
