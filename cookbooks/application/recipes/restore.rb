ruby_block "create the database" do
  block do
    command = <<-COMMAND
      PGPASSWORD=#{ENV['POSTGRESQL_PASSWORD']} createdb \
        --host=#{ENV['POSTGRESQL_HOST']} \
        --username=postgres \
        --owner=postgres \
        gemcutter_development
    COMMAND
    Chef::Log.debug command

    system command
  end

  not_if do
    command = <<-COMMAND
      PGPASSWORD=#{ENV['POSTGRESQL_PASSWORD']} psql \
        --host=#{ENV['POSTGRESQL_HOST']} \
        --username=postgres \
        --dbname=gemcutter_development \
        --command '' > /dev/null 2>&1
    COMMAND
    Chef::Log.debug command

    system command
  end
end

ruby_block "restore the database" do
  # NOTE: Dump created with
  #       $ pg_dump --format=p --inserts --no-owner --no-privileges --exclude-table=delayed_jobs gemcutter_development
  #
  block do
    command = <<-COMMAND
      curl -# https://s3.amazonaws.com/webexpo-chef/gemcutter_development.sql | \
      PGPASSWORD=#{ENV['POSTGRESQL_PASSWORD']} psql \
        --host=#{ENV['POSTGRESQL_HOST']} \
        --username=postgres \
        --dbname=gemcutter_development
    COMMAND
    Chef::Log.debug command

    system command
  end

  not_if do
    command = <<-COMMAND
    PGPASSWORD=#{ENV['POSTGRESQL_PASSWORD']} psql \
        --host=#{ENV['POSTGRESQL_HOST']} \
        --username=postgres \
        --dbname=gemcutter_development \
        --command 'SELECT id FROM rubygems LIMIT 1;'
    COMMAND
    Chef::Log.debug command

    system command
  end
end
