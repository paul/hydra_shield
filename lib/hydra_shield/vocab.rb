class HydraShield::Vocab

  attr_reader :supported_classes

  INTERNAL_CLASSES = [
    "HydraShield::ResourceShield",
    "HydraShield::CollectionShield",
    "HydraShield::VocabShield"
  ]

  def initialize(supported_classes)
    @supported_classes = (supported_classes - INTERNAL_CLASSES.map(&:constantize))
  end
end

