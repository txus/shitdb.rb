require 'yaml'
require_relative 'core_ext'

module ShitDB
  class DB
    attr_reader :name

    def initialize(name)
      @name = File.join(File.dirname(__FILE__), name)
    end

    def collection(name)
      Collection.new(self, name)
    end

    def file
      @file ||= persisted_file
    end

    def persisted_file
      if File.exist?(@name)
        to_read = ""
        while to_read == ""
          File.open(@name, 'r+') do |f|
            to_read = f.read
          end
        end

        YAML.load(to_read)
      else
        {}
      end
    end

    def persist!
      new_file = nil
      new_file = persisted_file.rmerge(@file)

      to_write = YAML.dump(new_file)

      result = nil
      begin
        File.open(@name, 'w') do |f|
          f.write to_write
        end
      end
      result
    end
  end
end
