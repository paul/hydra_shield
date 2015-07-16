module HydraShield
  class EntryPointShield < HydraShield::ResourceShield

    self.id   = -> { entry_point_path }
    self.type = "EntryPoint"

    operation :entry_point,
              method: "GET",
              description: "The API main entry point",
              returns: type

    attr_reader :entry_point

    def attributes
      hydra_attributes.merge(entry_point.attributes)
    end

  end

end
