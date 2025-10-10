=begin class TodoController < ApplicationController
  
  def index
    @greeting = "Ruby on Rails"
    @array  = ["a","b","c",nil]
    #@ssss = detil(array)
  end

  def show
    @todo = params.slice(:title, :body)
  end

  def show_post
    @show = "show"
  end

  def detil(array)
    @Ruby = array[0]

    return @Ruby
  end
end
=end

class TodosController < ApplicationController
  def new
    @todo = Todo.new
  end

  def confirm
    @todo = Todo.new(todo_params)
    render :new unless @todo.valid?  # バリデーションNGなら入力画面に戻す
  end

  def back
    @todo = Todo.new(todo_params)
    render :new
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to complete_todos_path, notice: "Todoを作成しました!!!!"
    else
      render :new
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :body)
  end
end
