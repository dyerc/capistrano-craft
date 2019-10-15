module Capistrano
  module DSL
    module Craft
      def craft_app_path
        release_path.join(fetch(:app_path))
    end
  end
end