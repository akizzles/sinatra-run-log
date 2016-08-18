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
      session[:error] = "An invalid username and/or password was entered. Please retry."
      redirect '/login'
    end
  end

  # NEW ACCOUNT SIGNUP
  get '/signup' do
    if !session[:runner_id]
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
      session[:runner_id] = @runner.id
      redirect '/workouts'
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

  get '/runner/:id' do
    if !logged_in?
      redirect '/'
    end

    @runner = Runner.find(params[:id])
    if !@runner.nil? && @runner == current_user
      erb :'runners/show'
    else
      redirect '/'
    end
  end

  # LIST OF WORKOUTS
  get '/workouts' do
    puts params
    redirect_if_not_logged_in
    @workouts = Workout.all
    if @workouts == nil
      redirect '/workouts/new'
    else
      erb :'/workouts/index'
    end
  end

  # CREATE A NEW RUNNING WORKOUT
  get '/workouts/new' do
    redirect_if_not_logged_in
    @error_message = params[:error]
    erb :'/workouts/new'
  end

  post '/workouts' do
    puts params
    redirect_if_not_logged_in
    if params[:day] == "" || params[:type] == ""
      redirect '/workouts/new?error=please fill in the workout date and type'
    else
      @workout = Workout.create(day: params[:day], effort: params[:effort_level], distance: params[:distance], time: params[:time], runner_id: current_user.id)
      redirect '/workouts'
    end

  end

  # VIEW ONLY THE SPECIFIC WORKOUT 
  get '/workouts/:id' do
    puts params
    redirect_if_not_logged_in
    @workout = Workout.find(params[:id])
    erb :'/workouts/show'
  end

  # EDIT A WORKOUT
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
      @workout.save
      redirect to "/workouts/#{@workout.id}"
    end
  end

  # DELETE A WORKOUT
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


 # RUN TYPE

 get "/runtypes" do
  redirect_if_not_logged_in
  @run_types = RunType.all
  erb :'run_types/index'
 end

 get "/runtypes/new" do
  redirect_if_not_logged_in
  binding.pry
  @error_message = params[:error]
  @workouts = Workout.all
  erb :'run_types/new'
 end

 get "/runtypes/:id/edit" do
  redirect_if_not_logged_in
  @error_message = params[:error]
  @run_type = RunType.find(params[:id])
  erb :'run_types/edit'
 end

 post "/runtypes/:id" do
  redirect_if_not_logged_in
  @run_type = RunType.find(params[:id])
  if params[:type].empty?
    redirect "/runtypes/#{@run_type.id}/edit?error=please select a run type"
  else
    @run_type.update(name: params[:name])
  end
 end

 get "runtypes/:id" do
  redirect_if_not_logged_in
  @run_type = RunType.find(params[:id])
  erb :'run_types/show'
 end

 post "/runtypes" do
  redirect_if_not_logged_in
  RunType.create(params)
  redirect "/runtypes"
 end

  # SHOW WORKOUTS BY RUN TYPE
  # get '/workouts/:slug' do
  #   binding.pry
  #   @workout = Workout.where(runner_id: current_user.id).find_by_slug(params[:slug])
  #   if current_user
  #     erb :'/workouts/show_by_runtype'
  #   else
  #     redirect '/'
  #   end
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