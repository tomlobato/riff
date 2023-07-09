# frozen_string_literal: true

# TODO: implement lazy properties

module Riff
  module Request
    class Context
      attr_accessor :user, :scope

      include WebRequest
      include Resource
      include Action
      include Model

      def initialize(request)
        @request = request
      end

      def raw_request
        request
      end

      def settings
        @settings ||= (custom_settings || Settings.new)
      end

      def enabler
        @enabler ||= (custom_enabler || Enable.new)
      end

      def custom
        @custom ||= load_custom
      end

      private

      attr_reader :request

      def settings_class_path
        [Conf.resources_base_module, module_name, :Settings]
      end

      def custom_settings
        Util.const_get(settings_class_path, anchor: true)&.new
      end

      def enabler_class_path
        [Conf.resources_base_module, module_name, :Enable]
      end

      def custom_enabler
        Util.const_get(enabler_class_path, anchor: true)&.new
      end

      def load_custom
        store = OpenStruct.new
        if (klass = Conf.custom_context_class)
          klass.new(self).call.to_h.each { |k, v| store[k] = v unless v.nil? }
        end
        store
      end
    end
  end
end
