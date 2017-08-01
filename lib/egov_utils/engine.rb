module EgovUtils
  class Engine < ::Rails::Engine
    isolate_namespace EgovUtils

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

    initializer 'egov_utils.grid_setup' do
      require 'grid/shield_grid'
      ActiveSupport::Reloader.to_prepare do
        ActiveSchema::Outputs.register(Grid::ShieldGrid)
      end
    end

    # initializer "active_record.include_plugins" do
    #   ActiveSupport.on_load(:active_record) do
    #     require 'egov_utils/has_audit_trail'
    #     include EgovUtils::HasAuditTrail
    #   end
    # end

    initializer 'egov_utils.user_setup' do
      ActiveSupport.on_load(:action_controller) do
        require 'egov_utils/user_utils/application_controller_patch'
        include EgovUtils::UserUtils::ApplicationControllerPatch

        helper EgovUtils::GridHelper
      end
    end
  end
end
