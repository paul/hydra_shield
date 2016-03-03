module HydraShield
  class Engine < ::Rails::Engine
    isolate_namespace HydraShield

    ::Mime::Type.register "application/ld+json", :jsonld, ["application/json"]
  end
end
