require './spec/support/attribute_matchers'

require 'shield'

describe Shield::ResourceShield do

  class TestShield < Shield::ResourceShield

    self.id   = -> { test_path(self) }
    self.type = "Test"

    property :title, :string, "The title of the thing"
    property :widgets, :collection, "A nested collection"

    attr_reader :test

    def to_param
      1
    end

    def title
      "Test Shield Title"
    end

    def widgets
      collection_shield widgets: 3.times.map { |w| TestWidget.new(w)},
                        collection_id: "/widgets",
                        with: TestWidgetShield
    end

  end

  class TestWidgetShield < Shield::ResourceShield

    self.id   = -> { widget_path(widget) }
    self.type = "Widget"

    property :title, :string, "The title of the thing"

    attr_reader :widget

    def title
      "Widget ##{widget.id}"
    end

  end

  class MockController < Struct.new(:request)

    def test_path(test)
      "/tests/#{test.to_param}"
    end

    def widget_path(widget)
      "/widgets/#{widget.id}"
    end

    def context_path(params)
      "/contexts/#{params[:type]}"
    end
  end

  class TestWidget < Struct.new(:id); end

  let(:controller) { MockController.new("test.example") }
  let(:widget)  { TestWidget.new(1) }

  subject(:shield) { TestShield.new(controller, widget: widget) }

  describe "produces attributes"  do
    subject(:attributes) { shield.attributes }

    describe "required by Hyrda" do

      it { should have_attribute "@id",      eq("/tests/1")       }
      it { should have_attribute "@type",    eq("Test")           }
      it { should have_attribute "@context", eq("/contexts/Test") }

    end

    context "defined by the user" do
      it { should have_attribute "title", eq("Test Shield Title") }
    end

    context "that are links" do

    end

    context "that are collections" do
      subject(:collection) { attributes[:widgets] }

      it { should have_attribute "@id",      eq("/widgets")             }
      it { should have_attribute "@type",    eq("Collection")           }
      it { should have_attribute "@context", eq("/contexts/Collection") }
      it { should have_attribute "member"                               }

    end

  end

end
