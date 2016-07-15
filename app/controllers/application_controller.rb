require './config/environment'

class ApplicationController < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  # HOME PAGE
  get '/' do
    erb :index
  end

  #LOGIN
  get '/login' do
    if logged_in?
      redirect '/workouts'
    else
      erb :'runners/login'
    end
  end

  post '/login' do
    puts params
    @runner = Runner.find_by(username: params[:username])
    if @runner && @runner.authenticate(params[:password])
      session[:runner_id] = @runner.id
      redirect '/workouts/new'
    else
      session[:error] = "An invalid username and/or password was entered. Please retry."
      redirect '/login'
    end
  end


  # CREATE A NEW ACCOUNT
  get '/signup' do
    if !logged_in?
      erb :'/runners/create_runner'
    else
      redirect '/workouts'
    end
  end

  post '/signup' do
    puts params
    if params[:username] == "" || params[:email] == "" || params[:password] == ""
      redirect '/signup'
    else
      @runner = Runner.new(username: params[:username], email: params[:email], password: params[:password])
      @runner.save
      session[:runner_id] = @runner.id
      redirect '/workouts'
    end
  end


  # LIST OF RUNNER'S WORKOUTS
  get '/workouts' do
    if logged_in?
      @workouts = Workout.all
      erb :'/workouts/workouts'
    else
      redirect '/login'
    end
  end

  # CREATE A NEW RUNNING WORKOUT
  get '/workouts/new' do
    if logged_in?
      erb :'/workouts/create_workout'
    else
      redirect '/login'
    end
  end


  post '/workouts' do
    if params[:day] == "" || params[:type] == "" || params[:time] == "" || params[:distance] == ""
      redirect '/workouts/new'
    else
      @workout = Workout.create(day: params[:day], distance: params[:distance], time: params[:time])
      @workout.type << RunType.create(type: params[:type])
      redirect '/workouts/#{@workout.id}'
    end
  end


  # VIEW ONLY THE SPECIFIC WORKOUT 
  get '/workouts/:id' do
    puts "This is working..."
  end


  # HELPER METHODS
  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end