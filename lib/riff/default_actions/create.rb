# frozen_string_literal: true

module Riff
  module DefaultActions
    class Create < Base
      include Helpers::Attributes

      def call
        rec = model_class.new(build_atts(attributes))
        rec.save
        after(rec)
        Request::Result.new(rec.values.slice(*fields))
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, Util.record_errors(rec.errors).to_json)
      end

      private

      def build_atts(atts)
        atts
          .slice(*only_keys(atts))
          .merge(extra_attributes.to_h)
          .merge(scope.to_h)
      end

      def only_keys(atts)
        atts.keys - ignore_attributes.to_a.map(&:to_sym)
      end

      def fields
        settings.show_fields || model_class.columns
      end

      def extra_attributes
        # may implement
      end

      def ignore_attributes
        # may implement
      end

      def after(rec)
        # may implement
      end
    end
  end
end
