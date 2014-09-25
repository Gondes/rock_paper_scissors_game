class User
  attr_accessor :name
  attr_accessor :games_played
  attr_accessor :wins_total
  attr_accessor :loss_total
  attr_accessor :ties_total
  attr_accessor :best_win_streak
  attr_accessor :current_win_streak

  def initialize
    @name = "Player"
    reset_stats
  end

  def display_stats
    puts "\n\n----------------Stats----------------"
    puts "              Name: #{@name}"
    puts "      Games Played: #{@games_played}"
    puts "        Wins Total: #{@wins_total}"
    puts "        Loss Total: #{@loss_total}"
    puts "        Ties Total: #{@ties_total}"
    puts "   Best Win Streak: #{@best_win_streak}"
    puts "Current Win Streak: #{@current_win_streak}"
    puts "-------------------------------------"
  end

  def reset_stats
    @games_played = 0
    @wins_total = 0
    @loss_total = 0
    @ties_total = 0
    @best_win_streak = 0
    @current_win_streak = 0
  end

  def win
    @games_played += 1
    @wins_total += 1
    @current_win_streak += 1
    if @current_win_streak > @best_win_streak
      @best_win_streak += 1
    end
  end

  def lose
    @games_played += 1
    @loss_total += 1
    @current_win_streak = 0
  end

  def tie
    @games_played += 1
    @ties_total += 1
  end
end