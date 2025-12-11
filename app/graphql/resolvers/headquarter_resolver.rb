module Resolvers
  class HeadquarterResolver < GraphQL::Schema::Resolver
    type Types::Objects::HeadquarterType, null: true

    argument :id, ID, required: true

    def resolve(id:)
      Headquarter.find(id)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end