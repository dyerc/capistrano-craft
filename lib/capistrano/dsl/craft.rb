module Capistrano
  module DSL
    module Craft
      def craft_app_path
        release_path.join(fetch(:app_path))
      end

      def craft_console_path
        release_path.join(fetch(:craft_console_path))
      end
      
      def craft_console(command, params = '')
        on release_roles(fetch(:craft_deploy_roles)) do
          execute fetch(:php), craft_console_path, command, params, fetch(:craft_console_flags)
        end
      end
    end
  end
end