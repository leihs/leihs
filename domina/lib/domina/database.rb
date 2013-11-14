require 'domina/system'

module Domina
  module Database
    class << self

      def create_db config
        puts Domina::System.execute_cmd! "mysql -u#{config['username']} --password=#{config['password']} -e 'drop database if exists #{config['database']}'"
        puts Domina::System.execute_cmd! "mysql -u#{config['username']} --password=#{config['password']} -e 'create database if not exists #{config['database']}'"
      end

      def drop_db config
        puts Domina::System.execute_cmd! "mysql -u#{config['username']} --password=#{config['password']} -e 'drop database if exists #{config['database']}'"
      end

    end
  end
end

