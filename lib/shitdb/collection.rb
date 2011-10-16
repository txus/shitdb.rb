module ShitDB
  class Collection
    attr_reader :db
    def initialize(db, name)
      @db   = db
      @name = name
      @db.file[@name] ||= {}
      @db.file["_#{@name}_last_id"] ||= 0
    end

    def persist!
      @db.persist!
    end

    def get(id)
      Document.new(id, @db.file[@name][id])
    end

    def put(doc)
      new_id = @db.file["_#{@name}_last_id"] + 1
      @db.file[@name][new_id] = doc
      @db.file["_#{@name}_last_id"] = new_id
    end

    def all
      Document.map(@db.file[@name])
    end

    def where(attrs)
      docs = @db.file[@name].select do |id, record|
        attrs.map do |attr|
          record[attr.first] == attr.last
        end.all?{|n| n == true}
      end
      Document.map(docs)
    end
  end
end
