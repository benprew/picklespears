class DivisionController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @divisions = Division.find(:all, :order => 'league')
  end

  def show
    @division = Division.find(params[:id])
  end

  def new
    @division = Division.new
  end

  def create
    @division = Division.new(params[:division])
    if @division.save
      flash[:notice] = 'Division was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @division = Division.find(params[:id])
  end

  def update
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      flash[:notice] = 'Division was successfully updated.'
      redirect_to :action => 'show', :id => @division
    else
      render :action => 'edit'
    end
  end

  def destroy
    Division.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
