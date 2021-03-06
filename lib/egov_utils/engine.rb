require 'haml'
require 'rails-i18n'

require 'i18n-js'
require 'cancancan'
require 'audited'
require 'paranoia'
require 'azahara_schema'
require 'azahara_schema_currency'

require 'font-awesome-sass'
require 'modernizr-rails'
require 'clipboard/rails'
require 'vuejs-rails'

require 'cookies_eu'

module EgovUtils
  class Engine < ::Rails::Engine
    isolate_namespace EgovUtils

    config.assets.paths << config.root.join('vendor', 'assets', 'fonts')
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    config.assets.precompile += %w(egov_utils/justice_logo.png)

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    initializer 'egov_utils.initialize_settings' do
      require 'egov_utils/settings'
    end

    initializer 'egov_utils.set_locales' do
      config.middleware.use I18n::JS::Middleware
    end

    initializer 'egov_utils.grid_setup' do
      require 'grid/shield_grid'
      ActiveSupport::Reloader.to_prepare do
        AzaharaSchema::Outputs.register(Grid::ShieldGrid)
      end
      ActiveSupport.on_load(:action_controller_base) do
        helper EgovUtils::ApplicationHelper
        helper EgovUtils::GridHelper
        helper EgovUtils::EnumHelper
      end
    end

    # initializer "active_record.include_plugins" do
    #   ActiveSupport.on_load(:active_record) do
    #     require 'egov_utils/has_audit_trail'
    #     include EgovUtils::HasAuditTrail
    #   end
    # end

    initializer 'egov_utils.user_setup' do
      require 'egov_utils/user_utils/role'
      require_dependency 'ability'
      ActiveSupport.on_load(:action_controller_base) do
        require 'egov_utils/user_utils/application_controller_patch'
        include EgovUtils::UserUtils::ApplicationControllerPatch
      end
      # require 'omniauth'
      # require 'omniauth-kerberos'
      # Rails.application.config.middleware.use OmniAuth::Builder do
      #   provider :kerberos
      # end
    end

    initializer 'egov_utils.view_helpers' do
      ActiveSupport.on_load(:action_view) do
        require 'egov_utils/helpers/form_helper'
        include ::EgovUtils::Helpers::FormHelper
      end
    end

    initializer 'egov_utils.bootstrap_form' do

      require 'bootstrap_form'

      require 'bootstrap_form/helpers/bootstrap4'
      # TODO: should be included in Helper, to support every submit tag
      BootstrapForm::FormBuilder.__send__(:prepend, BootstrapForm::Helpers::Bootstrap4)

      require 'bootstrap_form/datetimepicker'
      require 'bootstrap_form/fileuid'
      require 'bootstrap_form/select2'
      require 'bootstrap_form/custom_file_field'

      BootstrapForm::DATE_FORMAT_JS = 'YYYY-MM-DD'
      BootstrapForm::DATE_FORMAT_RUBY = BootstrapForm::DATE_FORMAT_JS.gsub('YYYY', "%Y").gsub('MM', "%m").gsub('DD', "%d")

      BootstrapForm::FormBuilder.__send__(:prepend, BootstrapForm::Datetimepicker)
      BootstrapForm::FormBuilder.__send__(:prepend, BootstrapForm::Fileuid)
      BootstrapForm::FormBuilder.__send__(:prepend, BootstrapForm::Select2)
      BootstrapForm::FormBuilder.__send__(:prepend, BootstrapForm::CustomFileField)

      require 'bootstrap_form/check_box_patch'
      BootstrapForm::FormBuilder.__send__(:prepend, BootstrapForm::CheckBoxPatch)

      #TODO: same as redefine method down?
      require 'egov_utils/helpers/tags/datetime_field_patch'
      ActionView::Helpers::Tags::DatetimeLocalField.prepend(EgovUtils::Helpers::Tags::DatetimeLocalFieldPatch)

      ActionView::Helpers::Tags::DateField.redefine_method(:format_date) do |value|
        value.try(:strftime, BootstrapForm::DATE_FORMAT_RUBY)
      end

      ActionView::Helpers::Tags::DatetimeLocalField.redefine_method(:format_date) do |value|
        value.try(:strftime, BootstrapForm::DATE_FORMAT_RUBY+"T%T")
      end
    end

    # config.after_initialize do
    #   Rails.application.reload_routes!
    #   OmniAuth.config.path_prefix = "#{Rails.application.routes.named_routes[:egov_utils].path.spec.to_s}/auth"
    # end

    initializer 'egov_utils.initialize_factory_paths', after: 'factory_bot.set_factory_paths' do
      if bot_module = 'FactoryBot'.safe_constantize
        FactoryBot.definition_file_paths << EgovUtils::Engine.root.join('spec', 'factories')
      end
    end

    initializer 'egov_utils.mock_resources' do
      if EgovUtils::Settings.mock_resources?
        EgovUtils::Love.mock!
      end
    end
  end
end
