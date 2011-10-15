require 'yaml'

module ShitDB
  class DB
    def initialize(name)
      @name = File.join(File.dirname(__FILE__), name)
    end

    def collection(name)
      Collection.new(self, name)
    end

    def file
      @file ||= File.exist?(@name) ? YAML.load(File.open(@name)) : {}
    end

    def persist
      File.open(@name, 'w') do |f|
        f.write YAML.dump(@file)
      end
    end
  end
end
