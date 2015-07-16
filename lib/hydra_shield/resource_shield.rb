require "active_support/core_ext/class/attribute"
require "active_support/core_ext/string/inflections"

module HydraShield
  class ResourceShield
    extend Forwardable

    class_attribute :type, :id, :label
    class_attribute :properties, :operations

    module ClassMethods
      def inherited(subclass)
        subclass.properties = (properties || []).dup
        subclass.operations = (operations || []).dup
      end

      def property(*args, &block)
        properties.push Property.new(*args, &block)
      end

      def link(*args, &block)
        properties.push Link.new(*args, &block)
      end

      def operation(name, attrs = {})
        operations.push Operation.new(*attrs.merge(name: name).values_at(*Operation.members))
      end

      def [](name)
        operations.detect { |op| op.name == name }
      end

      def include_timestamps
        property(:created_at, :timestamp, "When the resource was created")
        property(:updated_at, :timestamp, "When the resource was updated")
      end

      def description
      end

      def supported_operations
        operations.map do |op|
          {
            "@id" => op.id,
            "@type" => "hydra:Operation",
            "method" => op.method,
            "label" => op.label,
            "description" => op.description,
            "expects" => op.expects,
            "returns" => op.returns,
            "statusCodes" => op.status_codes || []
          }
        end
      end

      def supported_properties
        properties.map do |prop|
          {
            "hydra:description" => prop.description,
            "hydra:title" => prop.name,
            "readonly" => prop.readonly,
            "writeonly" => prop.writeonly,
            "required" => prop.required,
            "property" => {
              "@id" => "vocab:#{type}/#{prop.name}",
              "@type" => "rdf:Property",
              "description" => prop.description,
              "domain" => "vocab:#{type}",
              "label" => prop.name,
              "range" => "http://www.w3.org/2001/XMLSchema##{prop.type}",
              "supportedOperation" => prop.supported_operations
            }
          }
        end
      end

      def to_json(*a)
        {
          "@context" => {
            type => "vocab:#{type}",
            hydra: "http://www.w3.org/ns/hydra/core#",
            vocab: "/vocab"

          }
        }.to_json(*a)
      end
    end
    extend ClassMethods

    def type
      if self.class.type.is_a? Proc
        instance_exec(&self.class.type)
      else
        self.class.type
      end
    end

    def id
      instance_exec(&self.class.id)
    end

    attr_reader :controller, :objects

    def initialize(controller, objects)
      @controller = controller
      @objects = objects
      objects.each do |name, value|
        instance_variable_set :"@#{name}", value
      end
    end

    def properties
      self.class.properties
    end

    def hydra_attributes
      {
        "@context" => context,
        "@id" => id,
        "@type" => type
      }
    end

    def context
      controller.hydra_shield.context_path type: type, format: :jsonld
    end

    def attributes
      hydra_attributes.merge(
        Hash[properties.map { |prop| prop.call(self) }]
      )
    end

    def shield(objects)
      shield_klass = objects.delete(:with) or
                       const_get(primary_object.class.to_s + "Shield") or
                       raise ArgumentError, "No Shield found for #{primary_object.class.to_s}, please set one explicitly"

      shield = shield_klass.new(controller, objects)

      shield.attributes
    end

    def collection_shield(objects)
      collection_name = objects.keys.first
      item_name = collection_name.to_s.singularize.to_sym
      objects = objects.merge(collection_name: collection_name, item_name: item_name)
      shield = HydraShield::CollectionShield.new(controller, objects)
      shield.attributes
    end

    def method_missing(method_name, *a, &b)
      if method_name =~ /(_path|_url)$/
        self.class.delegate [ method_name ] => :controller
        send method_name, *a, &b
      else
        super
      end
    end

    class Property

      attr_reader :name, :type, :description, :readonly, :writeonly, :required
      def initialize(*args)
        @name, @type, @description = *args
      end

      def call(shield)
        [name, shield.send(name.to_sym)]
      end

      def supported_operations
        []
      end
    end

    class Link < Property
      def initialize(*args)
        @name, @description, @attrs = *args
      end

      def supported_operations
        if @attrs && @attrs[:operations]
          @attrs[:operations].map do |op|
            {
              "@id" => op.id,
              "@type" => "hydra:Operation",
              "method" => op.method,
              "label" => op.label,
              "description" => op.description,
              "expects" => op.expects,
              "returns" => op.returns,
              "statusCodes" => op.status_codes || []
            }
          end
        else
          []
        end
      end
    end

    class Operation < Struct.new(:name, :method, :label, :description, :expects, :returns, :status_codes)

      def id
        "_:#{name}"
      end
    end

  end
end

