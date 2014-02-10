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

def card_image(card)
  suit = case card[0]
  when 'H' then 'Hearts'
  when 'D' then 'Diamonds'
  when 'C' then 'Clubs'
  when 'S' then 'Spades'
end

value = card[1]
if ['J', 'Q', 'K', 'A'].include?(value)
  value = case card[1]
    when 'J' then 'Jack'
    when 'Q' then 'Queen'
    when 'K' then 'King'
    when 'A' then 'Ace'
  end
end


"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
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
  if params[:name].empty?
    @error = "Name is required"
    halt erb(:form)
  end

  session[:name] = params[:name]
  redirect '/game'
end


get '/game' do
  suits =  ['H','D','C','S']
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

  player_total = calc_total(session[:player_cards])
  if player_total == 21
    @success = "Congrats #{session[:name]} you hit Blackjack!"
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
    @error = "Sorry #{session[:name]} busted!!"
    @show_hit_or_stay_buttons = false
  end

  erb :game
end

post '/game/player/stay' do
@success = "#{session[:name]} has chosen to stay."
@show_hit_or_stay_buttons = false
  erb :game
end

