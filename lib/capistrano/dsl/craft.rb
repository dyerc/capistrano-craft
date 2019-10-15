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

      # Database

      def postgres_dump(env, output)
        execute SSHKit::Command.new <<-EOCOMMAND
          source "#{env}"
          PGPASSWORD=$DB_PASSWORD pg_dump -U $DB_USER -h $DB_SERVER -p $DB_PORT -F p --no-owner $DB_DATABASE > #{output}
        EOCOMMAND
      end

      def mysql_dump(env, output)
      end

      def postgres_restore(env, input)
        execute SSHKit::Command.new <<-EOCOMMAND
          source "#{env}"
          PGPASSWORD=$DB_PASSWORD dropdb -U $DB_USER -h $DB_SERVER -p $DB_PORT $DB_DATABASE
          PGPASSWORD=$DB_PASSWORD createdb -U $DB_USER -h $DB_SERVER -p $DB_PORT $DB_DATABASE
          PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_DATABASE -h $DB_SERVER -p $DB_PORT -q < "#{input}"
        EOCOMMAND
      end

      def mysql_restore(env, input)
      end

      def craft_database(env)
        driver = capture SSHKit::Command.new <<-EOCOMMAND
          source "#{env}"
          echo $DB_DRIVER
        EOCOMMAND

        case driver.strip
        when "pgsql" then return :pgsql
        when "mysql" then return :mysql
        else
          raise "Unable to determine remote server database driver"
        end
      end

      def database_dump(env, input)
        if craft_database(env) == :pgsql
          postgres_dump(env, input)
        else
          mysql_dump(env, input)
        end
      end

      def database_restore(env, input)
        if craft_database(env) == :pgsql
          postgres_restore(env, input)
        else
          mysql_restore(env, input)
        end
      end
    end
  end
end