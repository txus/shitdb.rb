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
          f = File.open(@name, 'r+')
          # f.flock(File::LOCK_EX | File::LOCK_NB)
          to_read = f.read
          # to_read = f.read_nonblock(10)
          # puts to_read.inspect
          # f.flock(File::LOCK_UN)
          f.close
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
        f = File.open(@name, 'w')
        # f.flock(File::LOCK_EX | File::LOCK_NB)
        puts "writing #{to_write}"
        f.write to_write
        # result = f.write_nonblock(to_write)
      # rescue IO::WaitWritable, Errno::EINTR
      #   IO.select(nil, [f])
      #   retry
      # ensure
        # f.flock(File::LOCK_UN)
        f.close
      end
      result
    end
  end
end
