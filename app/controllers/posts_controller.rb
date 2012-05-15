class PostsController < ApplicationController
  def create
    klass_name = params[:type]
    params[klass_name][:user_id] = current_user.id
    klass = Module.const_get(klass_name.capitalize)
    @post = klass.create(params[klass_name.downcase])
    unless @post.errors.any?
      render "create",
              :status => :ok,
              :handlers => [:jbuilder]
    else
      render "create",
              :status => :unprocessable_entity,
              :handlers => [:jbuilder]
    end
  end

  def index
    params[:page] = "0" if params[:page] && params[:page] == "NaN"
    @posts = current_user.posts.reverse.page(params[:page].to_i || 0)
  end
end
