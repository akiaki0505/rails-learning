module Mutations
  class CreateHeadquarter < BaseMutation
    # 1. 受け取る引数 (input)
    argument :name, String, required: true
    argument :code, String, required: true

    # 2. 返り値 (output)
    field :headquarter, Types::Objects::HeadquarterType, null: true
    field :errors, [String], null: false

    # 3. 実行される処理
    def resolve(name:, code: nil)
      headquarter = Headquarter.new(name: name, code: code)

      if headquarter.save
        { headquarter: headquarter, errors: [] }
        context[:controller].flash[:notice] = "Headquarter created successfully."
      else
        { headquarter: nil, errors: headquarter.errors.full_messages }
      end
    end
  end
end