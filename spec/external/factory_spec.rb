require 'spec_helper'

FactoryGirl.factories.map(&:name).each do |factory_name|
  describe "factory #{factory_name}" do
    factory = FactoryGirl.build(factory_name)

    it 'should be valid' do
      if factory.respond_to?(:valid?)
        expect(factory).to be_valid, lambda { factory.errors.full_messages.join(',') }
      end
    end

    describe "with trait" do
      FactoryGirl.factories[factory_name].definition.defined_traits.map(&:name).each do |trait_name|
        factories = FactoryGirl.build_list(factory_name, 5, trait_name)

        factories.each_with_index do |factory, index|
          it "should be valid with trait #{trait_name} (test n°#{index})" do
            if factory.respond_to?(:valid?)
              expect(factory).to be_valid, lambda { factory.errors.full_messages.join(',') }
            end
          end
        end
      end
    end
  end
end
