module Mutations
  class UpdateHeadquarter < BaseMutation
    
    argument :id, ID, required: true
    argument :name, String, required: true
    
    argument :code, String, required: false

    
    field :headquarter, Types::Objects::HeadquarterType, null: true
    field :errors, [String], null: false

    
    def resolve(id:, name:, code: nil)
      headquarter = Headquarter.find(id)
      
     
      if headquarter.update(name: name, code: code)
        
        
        context[:controller].flash[:notice] = "Headquarter updated successfully."

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