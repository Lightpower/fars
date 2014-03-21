require 'active_record'

namespace :spec do
  namespace :db do
    desc 'Setup DB for tests'
    task :setup do
      puts 'Create database\n'
      Rake::Task['spec:db:create'].invoke
      puts 'Migrate database\n'
      Rake::Task['spec:db:migrate'].invoke
    end

    desc 'Add tables required for tests'
    task :migrate do
      ActiveRecord::Base.establish_connection(db_config)

      ActiveRecord::Base.connection.execute(<<SQL
DROP TABLE IF EXISTS "public"."masters";

CREATE TABLE "public"."masters" (
	"id" int4 NOT NULL,
	"name" varchar(255) NOT NULL,
  "data" varchar(255),
	CONSTRAINT "masters_pkey" PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."masters" OWNER TO "rails";

DROP TABLE IF EXISTS "public"."slaves";

CREATE TABLE "public"."slaves" (
	"id" int4 NOT NULL,
	"master_id" int4,
  "name" varchar(255) NOT NULL,
  "data" varchar(255),
	CONSTRAINT "slaves_pkey" PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."slaves" OWNER TO "rails";

SQL
                                     )
    end

    desc 'Create DB for tests'
    task :create do
      encoding = db_config[:encoding] || ENV['CHARSET'] || 'utf8'
      begin
        ActiveRecord::Base.establish_connection(db_config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
        ActiveRecord::Base.connection.drop_database(db_config['database']) and puts "previously dropping DB..." if db_present?
        ActiveRecord::Base.connection.create_database(db_config['database'], db_config.merge('encoding' => encoding))
        ActiveRecord::Base.establish_connection(db_config)
      rescue
        $stderr.puts $!, *($!.backtrace)
        $stderr.puts "Couldn't create database for #{db_config.inspect}"
      end
    end

    def db_config
      root    = File.expand_path('../../', __FILE__)
      @db_conf ||= YAML.load_file("#{root}/config/database.yml")
    end

    def db_present?
      ActiveRecord::Base.connection.execute("SELECT count(*) FROM pg_database where datname = '#{db_config['database']}'").values.flatten.first.to_i == 1
    end
  end
end
