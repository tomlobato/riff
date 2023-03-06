# frozen_string_literal: true

module Riff
  module DefaultActions
    module Helpers
      class Order
        def initialize(params, model_class)
          @params = params
          @model_class = model_class
        end

        def order
          parse.presence || [nil]
        end

        private

        def parse
          @params[:_order].to_s.split(",").map do |field|
            parse_field(field)
          end
        end

        def parse_field(field)
          name, direction = field.split(":", 2)
          name = name.to_sym
          validate_field!(name)
          name = Sequel.desc(name) if direction.to_s.downcase == "desc"
          name
        end

        def validate_field!(name)
          raise_invalid_params!(name) unless @model_class.columns.include?(name)
        end

        def raise_invalid_params!(name)
          raise(Exceptions::InvalidaParameters, { order: name }.to_json)
        end
      end
    end
  end
end
