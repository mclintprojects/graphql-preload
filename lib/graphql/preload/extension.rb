module GraphQL
  module Preload
    # Provides an extension for the GraphQL::Field :preload definition
    class Extension < GraphQL::Schema::FieldExtension
      def resolve(object:, arguments:, context:)
        metadata = field.metadata
        return yield(object, arguments, context) if metadata.nil? || !object

        if metadata[:preload_scope]
          scope = metadata[:preload_scope].call(arguments, context)
        end

        is_graphql_object = object.is_a?(GraphQL::Schema::Object)
        respond_to_object = object.respond_to?(:object)
        record = is_graphql_object && respond_to_object ? object.object : object

        preload(record, metadata[:preload], scope).then do
          yield(object, arguments, context)
        end
      end

      private def preload(record, associations, scope)
        if associations.is_a?(String)
          raise TypeError, "Expected #{associations} to be a Symbol, not a String"
        elsif associations.is_a?(Symbol)
          return preload_single_association(record, associations, scope)
        end

        promises = []

        Array.wrap(associations).each do |association|
          case association
          when Symbol
            promises << preload_single_association(record, association, scope)
          when Array
            association.each do |sub_association|
              promises << preload(record, sub_association, scope)
            end
          when Hash
            association.each do |sub_association, nested_association|
              promises << preload_single_association(record, sub_association, scope).then do
                associated_records = record.public_send(sub_association)

                case associated_records
                when ActiveRecord::Base
                  preload(associated_records, nested_association, scope)
                else
                  Promise.all(
                    Array.wrap(associated_records).map do |associated_record|
                      preload(associated_record, nested_association, scope)
                    end
                  )
                end
              end
            end
          end
        end

        Promise.all(promises)
      end

      private def preload_single_association(record, association, scope)
        # We would like to pass the `scope` (which is an `ActiveRecord::Relation`),
        # directly into `Loader.for`. However, because the scope is
        # created for each parent record, they are different objects and
        # return different loaders, breaking batching.
        # Therefore, we pass in `scope.to_sql`, which is the same for all the
        # scopes and set the `scope` using an accessor. The actual scope
        # object used will be the last one, which shouldn't make any difference,
        # because even though they are different objects, they are all
        # functionally equivalent.
        loader = GraphQL::Preload::Loader.for(record.class, association, scope.try(:to_sql))
        loader.scope = scope
        loader.load(record)
      end
    end
  end
end
