class PlayerController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @player_pages, @players = paginate :players, :per_page => 10
  end

  def show
    @player = Player.find(params[:id])
  end

  def new
    @player = Player.new
    @player.teams << Team.find(params[:team])
  end

  def create
    @player = Player.new(params[:player])
    @player.team_ids = params[:player][:team_ids]
    if @player.save
      flash[:notice] = 'Player was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @player = Player.find(params[:id])
  end

  def update
    @player = Player.find(params[:id])
    if @player.update_attributes(params[:player])
      flash[:notice] = 'Player was successfully updated.'
      redirect_to :action => 'show', :id => @player
    else
      render :action => 'edit'
    end
  end

  def destroy
    Player.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
