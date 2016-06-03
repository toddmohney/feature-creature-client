require 'sinatra/base'

class App < Sinatra::Base
  set :haml, format: :html5

  get '/' do
    haml :index
  end

  get '/oauth-callback' do
    haml :oauth_callback, locals: { code: params[:code] }
  end
end

