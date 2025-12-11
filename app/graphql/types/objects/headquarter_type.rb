module Types
  module Objects
    class HeadquarterType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: true
      field :code, String, null: true
      
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :departments, [Types::Objects::DepartmentType], null: true
    end
  end
end
