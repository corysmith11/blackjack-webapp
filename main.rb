require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
INITIAL_POT_AMT = 2000

helpers do
  def calc_total(value)
    face_values = value.map{|card_value| card_value[1]}

    total = 0
    face_values.each do |val|
      if val == "ace"
        total += 11
      else
        total += val.to_i == 0 ? 10 : val.to_i
      end
    end

    #correct for Aces
    face_values.select{|card_value| card_value == "ace"}.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end


def card_image(card)
  suit = case card[0]
  when 'H' then 'hearts'
  when 'D' then 'diamonds'
  when 'C' then 'clubs'
  when 'S' then 'spades'
  end
end


"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:player_pot] = session[:player_pot] + session[:player_bet]
    @winner = "<strong>#{session[:name]} wins!</strong> #{msg}"
  end

  def loser!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @loser = "<strong>#{session[:name]} loses. Better luck next time!</strong> #{msg}"
  end

  def tie!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @winner ="<strong>It's a tie</strong> #{msg}"
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
  session[:player_pot] = INITIAL_POT_AMT
  erb :form
end

 post '/welcome' do
  if params[:name].empty?
    @error = "Name is required"
    halt erb(:form)
  end

  session[:name] = params[:name]
  redirect '/bet'
end

  get '/bet' do
    session[:player_bet] = nil
    erb :bet
  end
  
  post '/bet' do
    if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
      @error = "Must Make a Bet if you want to play!"
      halt erb(:bet)
    elsif params[:bet_amount].to_i > session[:player_pot]
      @error = "Bet Cannot be greater than what you have ($#{session[:player_pot]})"
      halt erb (:bet)
    else
      session[:player_bet] =params[:bet_amount].to_i
      redirect '/game'
    end
  end
  
get '/game' do
  session[:turn] = session[:name]

  #create a deck and put it in session
  suits =  ['H','D','C','S']
  cards =   ['2','3','4','5','6','7','8','9','10','jack','queen','king','ace']
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
  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[:name]} hit blackjack!")
  elsif player_total > BLACKJACK_AMOUNT
    loser! ("Sorry #{session[:name]} busted!! Dealer Wins")
  end

  erb :game, layout: false
end

post '/game/player/stay' do
@success = "#{session[:name]} has chosen to stay."
@show_hit_or_stay_buttons = false
redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false

  dealer_total = calc_total(session[:dealer_cards])
  
  if dealer_total == BLACKJACK_AMOUNT
    loser!("Sorry.. Dealer Hit Blackjack!")
  elsif dealer_total > BLACKJACK_AMOUNT
   winner!("Dealer busted at #{dealer_total}.")
  elsif dealer_total >= DEALER_MIN_HIT

    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
  
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false

  player_total = calc_total(session[:player_cards])
  dealer_total = calc_total(session[:dealer_cards])

  if player_total < dealer_total
    @error = "Sorry you lost!"
    loser!("#{session[:name]} stayed at #{player_total} and the Dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("#{session[:name]} stayed at #{player_total} and the Dealer stayed at #{dealer_total}.")
  else
    tie!("#{session[:name]} and the Dealer stayed at #{player_total}.")
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end