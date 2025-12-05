module Mutations
  class UpdateHeadquarter < BaseMutation
    # 1. 受け取る引数 (input)
    argument :id, ID, required: true
    argument :name, String, required: true

    # 2. 返り値 (output)
    field :headquarter, Types::Objects::HeadquarterType, null: true
    field :errors, [String], null: false

    # 3. 実行される処理
    def resolve(id:, name:)
      headquarter = Headquarter.find(id)
      
      if headquarter.update(name: name)
        {
          headquarter: headquarter,
          errors: []
        }
      else
        {
          headquarter: nil,
          errors: headquarter.errors.full_messages
        }
      end
    rescue ActiveRecord::RecordNotFound
      {
        headquarter: nil,
        errors: ["Headquarter not found"]
      }
    end
  end
end