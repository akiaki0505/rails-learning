module Elements
  class RadioOptionComponent < ViewComponent::Base
    def initialize(name:, value:, label:, icon:)
      @name = name
      @value = value
      @label = label
      @icon = icon
    end
  end
end