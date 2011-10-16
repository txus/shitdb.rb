require 'test_helper'
require 'fileutils'

module ShitDB
  describe 'acceptance tests' do
    before do
      @db = DB.new('my_db')
      @users = @db.collection(:users)
      FileUtils.rm(@db.name) if File.exist?(@db.name)
    end

    describe 'storage' do
      it 'saves records in memory' do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)

        users = @users.all.map(&:name)
        assert_equal 2, users.length
        assert_includes users, 'James'
        assert_includes users, 'John'
      end

      it 'does not save them to disk' do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)

        persisted = DB.new('my_db').collection(:users).all
        assert_equal 0, persisted.length
      end

      it 'persists them when told so' do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)

        @users.persist!

        users = DB.new('my_db').collection(:users).all.map(&:name)
        assert_equal 2, users.length
        assert_includes users, 'James'
        assert_includes users, 'John'
      end

      it 'merges records when persisting' do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)

        file = {}

        file[:users] ||= {}
        file[:users][1] ||= {}
        file[:users][1][:name] = 'Charlie'
        file[:users][1][:age] = 91

        File.open(@users.db.name, 'w') do |f|
          f.write YAML.dump(file)
        end

        @users.persist!

        users = DB.new('my_db').collection(:users).all
        assert_equal 2, users.length

        names = users.map(&:name)
        ages  = users.map(&:age)

        assert_includes names, 'James'
        assert_includes names, 'John'

        assert_includes ages, 91
        assert_includes ages, 30
      end
    end

    describe 'querying' do
      before do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)
        @users.put(:name => 'Charles', :age => 30)
      end

      it 'performs simple queries with one condition inefficiently' do
        result = @users.where(:age => 30).map(&:name)
        assert_equal 2, result.length
        assert_includes result, 'John'
        assert_includes result, 'Charles'
      end

      it 'performs simple queries with multiple conditions inefficiently' do
        result = @users.where(:name => 'Charles', :age => 30).map(&:name)
        assert_equal 1, result.length
        assert_equal 'Charles', result.first
      end

      it 'retrieves records by id' do
        p @users.all
        james   = @users.get(1)
        john    = @users.get(2)
        charles = @users.get(3)

        assert_equal 'James',   james.name
        assert_equal 'John',    john.name
        assert_equal 'Charles', charles.name
      end
    end

    describe 'consistency' do
      it 'assigns autoincremental ids' do
        @users.put(:name => 'James')
        @users.put(:name => 'John')

        ids = @users.all.map(&:id).compact

        assert_equal 2, ids.length
        refute_equal ids.first, ids.last
      end
    end

    describe 'concurrency' do
      it 'locks the shared file on read/write' do
        (1..1).to_a.map do |t|
          if t % 2 == 0
            Thread.new do
              DB.new('my_db').persisted_file
            end
          else
            Thread.new do
              users = DB.new('my_db').collection('users')
              users.put(:some => 'doc')
              users.persist!
            end
          end
        end.map(&:join)

        assert_equal 500, DB.new('my_db').collection('users').all.length
      end
    end
  end
end
