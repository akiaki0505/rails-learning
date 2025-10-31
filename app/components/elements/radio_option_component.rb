module Elements
  class RadioOptionComponent < ViewComponent::Base
    def initialize(form:, attribute:, value:, label:, icon:)
      @form = form
      @attribute = attribute
      @value = value
      @label = label
      @icon = icon
    end
  end
end