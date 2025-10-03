class TodoController < ApplicationController
  def index
    @greeting = "Ruby on Rails"
    @array  = ["a","b","c",nil]
    #@ssss = detil(array)
  end

  def show
    @show = "show"
  end

  def detil(array)
    @Ruby = array[0]

    return @Ruby
  end
end