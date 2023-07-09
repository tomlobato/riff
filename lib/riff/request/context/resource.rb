# frozen_string_literal: true

module Riff
  module Request
    class Context
      module Resource
        def resource
          @resource ||= (Riff::Conf.resource_remap[path_node1.to_sym]&.to_s || path_node1)
        end

        def id
          @id ||= (id_and_custom_method[0] if id_and_custom_method)
        end

        def id=(val)
          @id = val
        end

        def custom_method
          id_and_custom_method[1] if id_and_custom_method
        end

        def module_name
          @module_name ||= path_node1.camelize
        end
  
        def path_nodes
          @path_nodes ||= path.split("/").reject(&:blank?)[1..]
        end

        private

        attr_reader :request

        def path_node1
          path_nodes[0]
        end

        def path_node2
          path_nodes[1]
        end

        def id_and_custom_method
          @id_and_custom_method ||= parse_path_node2
        end

        def parse_path_node2
          node = path_node2.to_s.presence
          return unless node
          return node.split(":", 2).map(&:presence) if node.index(":")

          case Conf.no_colon_mode
          when :id
            [node, nil]
          when :custom_method
            [nil, node]
          when :id_if_digits
            node.match?(Constants::ONLY_DIGITS) ? [node, nil] : [nil, node]
          when :id_if_uuid
            node.match?(Constants::UUID) ? [node, nil] : [nil, node]
          when :id_if_digits_or_uuid
            node.match?(Constants::ONLY_DIGITS) || node.match?(Constants::UUID) ? [node, nil] : [nil, node]
          else
            raise(StandardError, "Unknown no_colon_mode: #{Conf.no_colon_mode}")
          end
        end
      end
    end
  end
end
