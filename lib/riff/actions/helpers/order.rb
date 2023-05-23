# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      class Order
        def initialize(param_order, model_class, allow_extra_fields: nil)
          @param_order = param_order
          @model_class = model_class
          @allow_extra_fields = allow_extra_fields
        end

        def order
          parse.presence || [nil]
        end

        private

        def parse
          @param_order.to_s.split(",").map do |field|
            parse_field(field)
          end
        end

        def parse_field(field)
          name, direction = field.split(":", 2)
          name = name.to_sym
          validate_field!(name, direction)
          if name.to_s.include?('.')
            tbl, col = name.to_s.split('.')
            name = Sequel[tbl.to_sym][col.to_sym] 
          end
          name = Sequel.desc(name) if direction.to_s.downcase == "desc"
          name
        end

        def validate_field!(name, direction)
          raise_invalid_params!(name) unless @model_class.columns.include?(name) || @allow_extra_fields.to_a.map(&:to_sym).include?(name)
          raise_invalid_params!("#{name}:#{direction}") if direction.present? && !direction.to_s.downcase.in?(%w[desc asc])
        end

        def raise_invalid_params!(name)
          Exceptions::InvalidParameters.raise!(field_errors: { order: name })
        end
      end
    end
  end
end
