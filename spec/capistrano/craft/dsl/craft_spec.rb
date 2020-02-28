RSpec.describe "Craft" do
  # Suppress STDOUT from Capistrano
  original_stderr = $stderr
  original_stdout = $stdout

  before(:all) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end

  after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end

  context "Database" do
    it "detects configuration from old style verbose .env" do
      config = {}

      on(:local) do
        within "#{RSPEC_ROOT}/fixtures" do
          config = database_config("#{RSPEC_ROOT}/fixtures/old.env")
        end
      end

      expect(config).to eql({
        driver: :pgsql,
        host: "localhost",
        port: "5432",
        database: "craft"
      })
    end

    it "detects configuration from DB_DSN .env" do
      config = {}

      on(:local) do
        within "#{RSPEC_ROOT}/fixtures" do
          config = database_config("#{RSPEC_ROOT}/fixtures/db_dsn.env")
        end
      end

      expect(config).to eql({
        driver: :mysql,
        host: "0.0.0.0",
        port: "1234",
        database: "db_name"
      })
    end

    it "raises for unknown database driver" do
      expect {
        on(:local) do
          within "#{RSPEC_ROOT}/fixtures" do
            config = database_config("#{RSPEC_ROOT}/fixtures/unknown_db_driver.env")
          end
        end
      }.to raise_exception
    end
  end
end