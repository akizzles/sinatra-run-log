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
    session.clear
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
      redirect '/workouts'
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
      redirect '/logout'
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

  get '/logout' do
    if logged_in?
      session.clear
      redirect '/login'
    else
      redirect '/'
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
    puts params
    if params[:day] == "" || params[:type] == ""
      redirect '/workouts/new'
    else
      @workout = Workout.create(day: params[:day], effort: params[:effort_level], distance: params[:distance], time: params[:time], runner_id: current_user.id)
      @workout.run_types << RunType.new(name: params[:type])
      session[:workout_id] = @workout.id
      redirect '/workouts'
    end

  end

  # VIEW ONLY THE SPECIFIC WORKOUT 
  get '/workouts/:id' do
    if logged_in?
      @workout = Workout.find_by(id: params[:id])
      erb :'/workouts/show_workout'
    else
      redirect '/login'
    end
  end

  # EDIT A WORKOUT
  get '/workouts/:id/edit' do
    @workout = Workout.find_by(id: params[:id])
    if logged_in?
      erb :'/workouts/edit_workout'
    else
      redirect '/login'
    end
  end

  patch '/workouts/:id' do
    @workout = Workout.find_by(id: params[:id])
    @workout.update(params[:workout])
    @workout.save
    redirect to "/workouts/#{@workout.id}"
  end

  # DELETE A WORKOUT
  delete '/workouts/:id/delete' do
    @workout = Workout.find_by(id: params[:id])
    if logged_in? && @workout.runner_id == current_user.id
      @workout.destroy
      redirect '/workouts'
    else
      redirect '/'
    end
  end


  # FILTER BY RUN TYPE
  get '/workouts/:slug' do
    @workout = Workout.find_by_slug
    if current_user
      erb :/
  end






  # HELPER METHODS
  helpers do
    def logged_in?
      !!session[:runner_id]
    end

    def current_user
      Runner.find(session[:runner_id])
    end
  end

end