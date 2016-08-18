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


  # LOGIN
  get '/login' do
    @error_message = params[:error]
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
      @error_message = params[:error]
      redirect '/login'
    end
  end

  # NEW ACCOUNT SIGNUP
  get '/signup' do
    if !logged_in?
      erb :'/runners/new'
    else
      redirect '/logout'
    end
  end

  post '/signup' do
    puts params
    if params[:username] == "" || params[:password] == ""
      redirect '/signup'
    else
      @runner = Runner.new(username: params[:username], password: params[:password])
      @runner.save
      redirect '/login'
    end
  end

  # LOGOUT
  get '/logout' do
    if logged_in?
      session.clear
      redirect '/login'
    else
      redirect '/'
    end
  end

  # RUNNER LOOKUP

  # get '/runner/:id' do
  #   redirect '/' if !logged_in?
  #   @runner = Runner.find_by(username: params[:username])
  #   if !@runner.nil? && @runner == current_user
  #     erb :'runners/show'
  #   else
  #     redirect '/'
  #   end
  # end

  ### WORKOUT CONTROLLER ROUTES ###

  # INDEX
  get '/workouts' do
    puts params
    redirect_if_not_logged_in
    @workouts = Workout.all
    if @workouts.nil?
      redirect '/workouts/new'
    else
      erb :'/workouts/index'
    end
  end

  post '/workouts' do
    puts params
    redirect_if_not_logged_in
    if params[:day] == "" || params[:type] == ""
      redirect '/workouts/new?error=please fill in the workout date and type'
    else
      @workout = Workout.create(day: params[:day], effort: params[:effort_level], distance: params[:distance], time: params[:time], runner_id: current_user.id)
      @workout.run_type = RunType.create(name: params[:type], workout_id: @workout.id, runner_id: current_user.id)
      redirect '/workouts'
    end
  end

  # NEW
  get '/workouts/new' do
    redirect_if_not_logged_in
    @error_message = params[:error]
    erb :'/workouts/new'
  end

  # SHOW
  get '/workouts/:id' do
    puts params
    redirect_if_not_logged_in
    @workout = Workout.find(params[:id])
    erb :'/workouts/show'
  end

  # EDIT
  get '/workouts/:id/edit' do
    redirect_if_not_logged_in
    @error_message = params[:error]
    @workout = Workout.find(params[:id])
    erb :'/workouts/edit'
  end

  patch '/workouts/:id' do
    puts params
    redirect_if_not_logged_in
    @workout = Workout.find(params[:id])
    if params[:day] == "" || params[:type] == ""
      redirect "/workouts/#{@workout.id}/edit?error=please fill in the workout date and type"
    else
      @workout.update(day: params[:day], effort: params[:effort_level], distance: params[:distance], time: params[:time])
      @workout.run_type.update(name: params[:type])
      @workout.save
      redirect to "/workouts/#{@workout.id}"
    end
  end

  # DELETE
  delete '/workouts/:id/delete' do
    puts params
    @workout = Workout.find_by(id: params[:id])
    if session[:runner_id]
      @workout.destroy
      redirect '/workouts'
    else
      redirect '/'
    end
  end


 # SEARCH BY RUN TYPE

 # get "/runtypes" do
 #  redirect_if_not_logged_in
 #  @run_types = RunType.all
 #  erb :'run_types/index'
 # end

 # get "/runtypes/new" do
 #  redirect_if_not_logged_in
 #  @error_message = params[:error]
 #  @workouts = Workout.all
 #  erb :'run_types/new'
 # end

 # get "/runtypes/:id/edit" do
 #  redirect_if_not_logged_in
 #  @error_message = params[:error]
 #  @run_type = RunType.find(params[:id])
 #  erb :'run_types/edit'
 # end

 # post "/runtypes/:id" do
 #  redirect_if_not_logged_in
 #  @run_type = RunType.find(params[:id])
 #  if params[:type].empty?
 #    redirect "/runtypes/#{@run_type.id}/edit?error=please select a run type"
 #  else
 #    @run_type.update(name: params[:name])
 #  end
 # end

 # get "runtypes/:id" do
 #  redirect_if_not_logged_in
 #  @run_type = RunType.find(params[:id])
 #  erb :'run_types/show'
 # end

 # post "/runtypes" do
 #  redirect_if_not_logged_in
 #  RunType.create(params)
 #  redirect "/runtypes"
 # end

  # HELPER METHODS
  helpers do

    def redirect_if_not_logged_in
      if !logged_in?
        redirect "/login?error=You are not logged in"
      end
    end

    def logged_in?
      !!session[:runner_id]
    end

    def current_user
      Runner.find(session[:runner_id])
    end
  end

end