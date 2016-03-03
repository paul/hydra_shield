module HydraShield
  class CollectionShield < HydraShield::ResourceShield

    self.id = -> { controller.request.path }
    self.type = "Collection"

    property :member, :array

    attr_reader :collection

    def initialize(controller, collection)
      @controller = controller
      @collection = collection
    end

    def member
      collection.map do |item|
        shield(item)
      end
    end

  end
end

