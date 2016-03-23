module HydraShield::Helpers

  def shield(object, **options)
    if object.respond_to?(:each)
      shield_collection(object, **options)
    else
      shield_klass = intuit_shield_class(object, **options)
      shield_klass.new(self, object)
    end
  end

  def shield_collection(objects, **options)
    collection_class = intuit_shield_class(objects, **options)
    collection_class.new(self, objects)
  end

  def intuit_shield_class(object, **options)
    if object.respond_to?(:each)
      return options[:with_collection] if options.has_key?(:with_collection)

      possible_class_name = (object.respond_to?(model) ? object.model : object.first.class).to_s + "CollectionShield"
      return Object.const_get(possible_class_name) if Object.const_defined?(possible_class_name)

      HydraShield::CollectionShield
    else
      return options[:with] if options.has_key?(:with)

      possible_class_name = object.class.to_s
      return Object.const_get(possible_class_name) if Object.const_defined?(possible_class_name)

      raise ArgumentError, "No shield found for #{object.class.to_s}, " +
                           "please set one using the :with option " +
                           "or define a #{possible_class_name}"
    end
  end

end

