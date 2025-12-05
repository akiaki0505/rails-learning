module Types
  module Objects
    class DepartmentType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: true
      field :code, String, null: true
      
      # 日付系も一応残しておくと便利です
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
