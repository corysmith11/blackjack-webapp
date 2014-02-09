require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

helpers do
  def calc_total(value)
    face_values = value.map{|cardvalue| cardvalue[1]}

    total = 0
    face_values.each do |val|
      if val == "Ace"
        total += 11
      else
        total += val.to_i == 0 ? 10 : val.to_i
      end
    end

    face_values.select{|cardvalue| cardvalue == "ace"}.count.times do
      break if total <=21
      total -= 10
    end

    total
  end
end

before do
  @show_hit_or_stay_buttons = true
end


get '/' do
  if session[:name]
    redirect '/game'
  else
    redirect '/welcome'
  end
end

get '/welcome' do
  erb :form
end

post '/welcome' do
  session[:name] = params[:name]
  redirect '/game'
end

get '/game' do
  suits =  ['Hearts','Diamonds','Clubs','Spades']
  cards =   ['2','3','4','5','6','7','8','9','10','Jack','queen','king','ace']
  session[:deck] = suits.product(cards).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop


  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calc_total(session[:player_cards]) > 21
    @error = "Sorry you busted!!"
    @show_hit_or_stay_buttons = false
  end

  erb :game
end

post '/game/player/stay' do
@success = "You chosen to stay"
@show_hit_or_stay_buttons = false
  erb :game
end

