module ShitDB
  class Collection
    attr_reader :db

    def initialize(db, name)
      @db   = db
      @name = name
      @db.file[@name] ||= []
      @db.file["_#{@name}_last_id"] ||= 0
    end

    def persist
      @db.persist
    end

    def get(id)
      @db.file[@name].detect do |record|
        record[:id] == id
      end
    end

    def put(doc)
      new_id = @db.file["_#{@name}_last_id"] + 1
      @db.file[@name] << doc.update(:id => new_id)
      @db.file["_#{@name}_last_id"] = new_id
    end

    def all
      @db.file[@name]
    end

    def where(attrs)
      @db.file[@name].select do |record|
        attrs.map do |attr|
          record[attr.first] == attr.last
        end.all?{|n| n == true}
      end
    end
  end
end
