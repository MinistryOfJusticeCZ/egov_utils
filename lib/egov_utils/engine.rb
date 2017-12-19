require 'i18n-js'
require 'cancancan'
require 'audited'
require 'azahara_schema'

require 'font-awesome-sass'
require 'modernizr-rails'

require 'cookies_eu'

module EgovUtils
  class Engine < ::Rails::Engine
    isolate_namespace EgovUtils

    config.assets.paths << config.root.join('vendor', 'assets', 'fonts')
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    config.assets.precompile += %w(egov_utils/justice_logo.png)

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
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
      ActiveSupport.on_load(:action_controller) do
        ::ActionController::Base.helper EgovUtils::ApplicationHelper
        ::ActionController::Base.helper EgovUtils::GridHelper
        ::ActionController::Base.helper EgovUtils::EnumHelper
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
      ActiveSupport.on_load(:action_controller) do
        require 'egov_utils/user_utils/application_controller_patch'
        ::ActionController::Base.include EgovUtils::UserUtils::ApplicationControllerPatch
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

      require 'egov_utils/helpers/tags/datetime_field_patch'
      ActionView::Helpers::Tags::DatetimeField.prepend(EgovUtils::Helpers::Tags::DatetimeFieldPatch)

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
  end
end
