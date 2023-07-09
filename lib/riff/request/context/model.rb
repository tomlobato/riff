# frozen_string_literal: true

module Riff
  module Request
    class Context
      module Model
        def model_name
          @model_name ||= (settings.model&.to_s || default_model_name) unless settings.model_less
        end

        def model_class
          Util.const_get("::#{model_name}") unless settings.model_less
        end

        private

        def default_model_name
          path_node1.singularize.classify
        end
      end
    end
  end
end
