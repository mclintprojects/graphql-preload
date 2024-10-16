require "graphql"
require "graphql/batch"
require "promise.rb"

module GraphQL
  # Provides a GraphQL::Field definition to preload ActiveRecord::Associations
  module Preload
    autoload :Extension, "graphql/preload/extension"
    autoload :Loader, "graphql/preload/loader"
    autoload :VERSION, "graphql/preload/version"

    module SchemaMethods
      def enable_preloading
      end
    end

    module FieldMetadata
      attr_reader :metadata

      def initialize(*args, preload: nil, preload_scope: nil, **kwargs, &block)
        super(*args, **kwargs, &block)
        extension(Extension)
        self.preload(preload) if preload
        self.preload_scope(preload_scope) if preload_scope
      end

      def preload(associations)
        @metadata ||= {}
        @preload ||= []
        @preload.concat Array.wrap associations
        @metadata[:preload] = @preload
      end

      def preload_scope(scope_proc)
        @metadata ||= {}
        @preload_scope = scope_proc
        @metadata[:preload_scope] = @preload_scope
      end
    end
  end

  Schema.extend Preload::SchemaMethods
  Schema::Field.prepend Preload::FieldMetadata
end
