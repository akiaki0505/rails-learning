module Resolvers
  class DepartmentsResolver < GraphQL::Schema::Resolver
    type [Types::Objects::DepartmentType], null: false

    def resolve
      Department.all.order(:id)
    end
  
  end
end