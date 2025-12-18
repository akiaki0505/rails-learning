module Mutations
  class CreateHeadquarter < BaseMutation

    argument :name, String, required: true
    argument :code, String, required: true

    field :headquarter, Types::Objects::HeadquarterType, null: true
    field :errors, [String], null: false

    def resolve(name:, code: nil)
      headquarter = Headquarter.new(name: name, code: code)

      if headquarter.save
        context[:controller].flash[:notice] = "Headquarter created successfully."
        
        { headquarter: headquarter, errors: [] }
      else
        { headquarter: nil, errors: headquarter.errors.full_messages }
      end
    end
  end
end