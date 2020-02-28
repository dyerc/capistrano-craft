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

      def confirm(question)
        set :confirmed, proc {
          puts <<-EOF

  ************************** WARNING ***************************
  #{question}
  **************************************************************

          EOF
          ask :answer, "y/N"
          if fetch(:answer).strip == 'y' then true else false end
        }.call

        unless fetch(:confirmed)
          exit
        end
      end

      # Database

      def backup_file_name
        now = Time.now
        backup_date = [now.year, now.strftime("%m"), now.strftime("%d")]
        backup_time = [now.strftime("%H"), now.strftime("%M"), now.strftime("%S")]

        unless Dir.exist?(fetch(:craft_local_backups))
          Dir.mkdir(fetch(:craft_local_backups))
        end

        File.join(fetch(:craft_local_backups), "#{backup_date.join('-')}_#{backup_time.join('-')}.sql")
      end

      def postgres_dump(env, config, output)
        execute SSHKit::Command.new <<-EOCOMMAND
          source "#{env}"
          PGPASSWORD=$DB_PASSWORD pg_dump -U $DB_USER -h #{config[:host]} -p #{config[:port]} -F p --no-owner #{config[:database]} > #{output}
        EOCOMMAND
      end

      def mysql_dump(env, output)
      end

      def postgres_restore(env, config, input)
        execute SSHKit::Command.new <<-EOCOMMAND
          source "#{env}"
          PGPASSWORD=$DB_PASSWORD dropdb -U $DB_USER -h #{config[:host]} -p #{config[:port]} #{config[:database]}
          PGPASSWORD=$DB_PASSWORD createdb -U $DB_USER -h #{config[:host]} -p #{config[:port]} #{config[:database]}
          PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d #{config[:database]} -h #{config[:host]} -p #{config[:port]} -q < "#{input}"
        EOCOMMAND
      end

      def mysql_restore(env, input)
      end

      def database_config(env)
        config = capture SSHKit::Command.new <<-EOCOMMAND
          source "#{env}"
          echo "$DB_DSN,$DB_DRIVER,$DB_SERVER,$DB_PORT,$DB_DATABASE"
        EOCOMMAND

        params = config.split(",")
        parsed = {}

        if params[0].length > 0
          # Using the newer style DB_DSN config style
          dsn = params[0].split(":")

          # Split in config chunks eg. host=<host>
          database = dsn[1].split(";").map { |str|
            tuple = str.split("=")
            [tuple[0], tuple[1]]
          }.to_h

          parsed = {
            driver: dsn[0],
            host: database["host"],
            port: database["port"],
            database: database["dbname"]
          }
        else
          # Using the older style config style
          parsed = {
            driver: params[1],
            host: params[2],
            port: params[3],
            database: params[4]
          }
        end

        case parsed[:driver].strip
        when "pgsql" then parsed[:driver] = :pgsql
        when "mysql" then parsed[:driver] = :mysql
        else
          raise "Unable to determine database driver: \"#{parsed[:driver].strip}\""
        end

        return parsed
      end

      def database_dump(env, input)
        config = database_config(env)
        if config[:driver] == :pgsql
          postgres_dump(env, config, input)
        else
          mysql_dump(env, config, input)
        end
      end

      def database_restore(env, input)
        config = database_config(env)
        if config[:driver] == :pgsql
          postgres_restore(env, config, input)
        else
          mysql_restore(env, config, input)
        end
      end
    end
  end
end