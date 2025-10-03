class TodoController < ApplicationController
  def index
    @greeting = "Ruby on Rails"
    @ssss = detil()
  end

  def show
    @show = "show"
  end

  def detil
    @Ruby = "Ruby"

    return @Ruby
  end
end