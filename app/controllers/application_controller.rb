require './config/environment'

class ApplicationController < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  # Home page
  get '/' do
    erb :index
  end

  get '/login' do
    if logged_in?
      redirect to "/workouts"
    else
      erb :'runners/login'
    end
  end

  post '/login' do
    @runner = Runner.find_by(username: params[:username])
    if @runner && @runner.authenticate(params[:password])
      session[:runner_id] = @runner.id
      redirect to "/workouts"
    else
      session[:error] = "An invalid username and/or password was entered. Please retry."
      redirect to "/login"
    end
  end

  get '/signup' do
    
  end



  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end