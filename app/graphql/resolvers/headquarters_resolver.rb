module Resolvers
  class HeadquartersResolver < GraphQL::Schema::Resolver
    type [Types::Objects::HeadquarterType], null: false

    def resolve
      Headquarter.all.order(:id)
    end
  
  end
end