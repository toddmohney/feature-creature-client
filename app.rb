require 'sinatra/base'

class App < Sinatra::Base
  set :haml, format: :html5

  get '/' do
    haml :index
  end
end

