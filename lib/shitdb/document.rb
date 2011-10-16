module ShitDB
  class Document
    attr_reader :id, :doc

    def self.map(hash)
      hash.map do |k, v|
        Document.new(k, v)
      end
    end

    def initialize(id, doc)
      @id  = id
      @doc = doc
    end

    def method_missing(m, *a, &b)
      @doc[m.to_sym] || super
    end
  end
end
