class ArticlesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @articles = Article.find(:all)
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
    @article.lastupdate = Date.new(2007, 4, 1)
  end

  def create
    @article = Article.new(params[:article])
    if @article.save
      flash[:notice] = _('Article was successfully created.')
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def multi_error_messages_for
    @user = User.new
    @user.lastupdate = Date.new(2007, 4, 1)
    @article = Article.new
    @article.lastupdate = Date.new(2007, 4, 1)
    @user.valid?
    @article.valid?
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = _('Article was successfully updated.')
      redirect_to :action => 'show', :id => @article
    else
      render :action => 'edit'
    end
  end

  def destroy
    Article.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
