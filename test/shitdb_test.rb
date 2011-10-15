require 'test_helper'
require 'fileutils'

module ShitDB
  describe 'acceptance tests' do
    before do
      FileUtils.rm('my_db') if File.exist?('my_db')
      @users = DB.new('my_db').collection('users')
    end

    after do
      FileUtils.rm('my_db') if File.exist?('my_db')
    end

    describe 'storage' do
      it 'saves records in memory' do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)

        users = @users.all.map { |record| record[:name] }
        assert_equal 2, users.length
        assert_includes users, 'James'
        assert_includes users, 'John'
      end

      it 'does not save them to disk' do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)

        persisted = DB.new('my_db').collection('users').all
        assert_equal 0, persisted.length
      end

      it 'persists them when told so' do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)

        @users.persist

        users = DB.new('my_db').collection('users').all.map { |record| record[:name] }
        assert_equal 2, users.length
        assert_includes users, 'James'
        assert_includes users, 'John'
      end
    end

    describe 'querying' do
      before do
        @users.put(:name => 'James')
        @users.put(:name => 'John', :age => 30)
        @users.put(:name => 'Charles', :age => 30)
      end

      it 'performs simple queries with one condition inefficiently' do
        result = @users.where(:age => 30).map { |record| record[:name] }
        assert_equal 2, result.length
        assert_includes result, 'John'
        assert_includes result, 'Charles'
      end

      it 'performs simple queries with multiple conditions inefficiently' do
        result = @users.where(:name => 'Charles', :age => 30).map { |record| record[:name]}
        assert_equal 1, result.length
        assert_equal 'Charles', result.first
      end

      it 'retrieves records by id' do
        james   = @users.get(1)
        john    = @users.get(2)
        charles = @users.get(3)

        assert_equal 'James',   james[:name]
        assert_equal 'John',    john[:name]
        assert_equal 'Charles', charles[:name]
      end
    end

    describe 'consistency' do
      it 'assigns autoincremental ids' do
        @users.put(:name => 'James')
        @users.put(:name => 'John')

        ids = @users.all.map { |record| record[:id] }.compact

        assert_equal 2, ids.length
        refute_equal ids.first, ids.last
      end
    end
  end
end
