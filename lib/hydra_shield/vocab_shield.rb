
class HydraShield::VocabShield < HydraShield::ResourceShield

  self.id   = -> { vocab_path }
  self.type = "ApiDocumentation"

  attr_reader :vocab

  def context
    {
      vocab: vocab_path,
      hydra: "http://www.w3.org/ns/hydra/core#",
      ApiDocumentation: "hydra:ApiDocumentation",
      property: {
        "@id" => "hydra:property",
        "@type" => "@id"
      },
      readonly: "hydra:readonly",
      writeonly: "hydra:writeonly",
      supportedClass: "hydra:supportedClass",
      supportedProperty: "hydra:supportedProperty",
      supportedOperation: "hydra:supportedOperation",
      method: "hydra:method",
      expects: {
          "@id" => "hydra:expects",
          "@type" => "@id"
      },
      returns: {
          "@id" => "hydra:returns",
          "@type" => "@id"
      },
      statusCodes: "hydra:statusCodes",
      code: "hydra:statusCode",
      rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      rdfs: "http://www.w3.org/2000/01/rdf-schema#",
      label: "rdfs:label",
      description: "rdfs:comment",
      domain: {
          "@id" => "rdfs:domain",
          "@type" => "@id"
      },
      range: {
          "@id" => "rdfs:range",
          "@type" => "@id"
      },
      subClassOf: {
          "@id" => "rdfs:subClassOf",
          "@type" => "@id"
      }
    }
  end

  def attributes
    hydra_attributes.merge( supportedClass: supported_classes )
  end

  def supported_classes
    [
      {
        "@id" => "http://www.w3.org/ns/hydra/core#Resource",
        "@type" => "hydra:Class",
        "hydra:title" => "Resource",
        "hydra:description" => nil,
        "supportedOperation" => [],
        "supportedProperty" => []
      },
      {
        "@id" => "http://www.w3.org/ns/hydra/core#Collection",
        "@type" => "hydra:Class",
        "hydra:title" => "Collection",
        "hydra:description" => nil,
        "supportedOperation" => [],
        "supportedProperty" => [
          {
            "property" => "http://www.w3.org/ns/hydra/core#member",
            "hydra:title" => "members",
            "hydra:description" => "The members of this collection.",
            "required" => nil,
            "readonly" => false,
            "writeonly" => false
          }
        ]
      }
    ] + @vocab.supported_classes.map do |klass|
      {
        "@id" => "vocab:#{klass.type}",
        "@type" => "hydra:Class",
        "subClassOf" => nil,
        "label" => klass.label,
        "description" => klass.description,
        "supportedOperation" => klass.supported_operations,
        "supportedProperty" => klass.supported_properties
      }
    end
  end


end
