#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/sinatra/lib'

require 'sinatra'
require 'user'
require 'division'
require 'team'

set :root, Dir.pwd
set :views, Dir.pwd + '/views'
set :public, Dir.pwd + '/public'

class PickleSpears
  get '/' do
    @user = request.cookies["user"]
    haml :index
  end
  
  get '/browse' do
    @divisions = Division.find_all_by_league(params[:league], :order => 'name')
    @league = params[:league]
    haml :browse
  end

  get '/sign_in' do
    haml :sign_in
  end

  post '/sign_in' do
    cookie = request.cookies["user"]
    cookie = {
      :domain => 'throwingbones.com',
      :name => 'user',
      :value => params[:username],
    }
      
    set_cookie("user", cookie)
    @user = cookie[:value]
    redirect '/'
  end
  
  get '/team' do
    @team = Team.find(params[:team_id])
  
    haml :team_home
  end

  get '/search' do
    @teams = Team.find(:all, :conditions => [ "name like ?", '%' + params[:team].upcase + '%' ], :order => 'name')

    if @teams.length == 0
      haml "%h1 No @teams found"
    elsif @teams.length == 1
      redirect "team?team_id=#{@teams[0].id.to_s}"
    else
      haml :search
    end
  end

  get '/stylesheet.css' do
    headers 'Content-Type' => 'text/css'
    sass :stylesheet
  end
end

helpers do
  def title(title=nil)
      @title = title unless title.nil?
      @title
  end
end

