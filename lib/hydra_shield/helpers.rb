module HydraShield::Helpers

  def shield(objects)
    primary_object = objects.values.first
    shield_klass = objects.delete(:with) or
                   const_get(primary_object.class.to_s + "Shield") or
                   raise ArgumentError, "No Shield found for #{primary_object.class.to_s}, please set one explicitly"

    shield = shield_klass.new(self, objects)
    render json: shield.attributes
  end

  def collection_shield(objects)
    collection_name = objects.keys.first
    item_name = collection_name.to_s.singularize.to_sym
    objects = objects.merge(collection_name: collection_name, item_name: item_name)
    shield = HydraShield::CollectionShield.new(self, objects)
    render json: shield.attributes
  end

end

