class PagesController < ApplicationController
  def home
    @greeting = "Ruby on Rails"
    @numbers = [1, 2, 3, 4, 5]
  end
end
