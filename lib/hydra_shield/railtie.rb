require "rails/railtie"

module HydraShield
  class Railtie < Rails::Railtie

    config.after_initialize do |app|
      app.config.paths.add "app/shields", eager_load: true
    end

    initializer "shield.setup_action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        self.class_eval { include HydraShield::Helpers }
      end
    end
  end
end

