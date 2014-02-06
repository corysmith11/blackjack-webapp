require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true


get '/template' do
  erb :mytemplate
end

get '/form' do
  erb :form
end

post '/myaction' do
  params['name']
end


