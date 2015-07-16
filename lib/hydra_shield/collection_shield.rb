module HydraShield
  class CollectionShield < HydraShield::ResourceShield

    self.id = -> { collection_id }
    self.type = "Collection"

    property :member, :array

    attr_reader :collection_id

    def member
      collection.map do |item|
        shield(objects.merge(item_name => item))
      end
    end

    def item_name
      objects[:item_name] || :item
    end

    def collection_name
      objects[:collection_name] || :member
    end

    def collection
      objects[collection_name]
    end
  end
end

