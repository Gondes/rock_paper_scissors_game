#press ctrl-shift-b to run code
#require '../2Dspace/2Dspace'
require 'sqlite3'

class RockPaperScissors

  def initialize
    open_game_database
    @player_name = "Player"
    generate_win_array
    reset_stats
    display_stats
    menu
  end

  def generate_win_array
    @chart = [["Chart", "Rock", "Paper", "Scissors", "Nothing"], ["Rock", 0, -1, 1, 1], ["Paper", 1, 0, -1, 1], ["Scissors", -1, 1, 0, 1], ["Nothing", -1, -1, -1, 0]]
    #print @chart
  end

  def display_stats
    puts "\n\n----------------Stats----------------"
    puts "              Name: #{@player_name}"
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
    puts "\n\n--------Stats have been reset--------"
  end

  def display_menu_options
    puts "\n\n------Rock Paper Scissors Menu!------"
    puts "Hello #{@player_name}!"
    puts "1. Start New Game"
    puts "2. Display Stats"
    puts "3. Reset Stats"
    puts "4. Login"
    puts "5. Save Stats"
    #puts "6. Delete Current User"
    puts "9. Exit"
    puts "-----Please enter a valid number-----"
  end

  def menu
    i = 0

    until i.eql? 9
      display_menu_options
      i = gets.chomp.to_i
      #i = 1 + i.to_i
      #puts "You have entered #{i}"
      case i
      when 1
        game
      when 2
        display_stats
      when 3
        reset_stats
      when 4
        display_login_menu
      when 5
        save_game_record
      when 9
        close_game_database
        puts "Thank you for playing!\n\n"
      else
      end
    end
  end

#----------------------------------GAME LOGIC----------------------------------#

  def game_options
    puts "\n\n---Pick your hand!---"
    puts "1. Rock"
    puts "2. Paper"
    puts "3. Scisors"
    puts "9. I quit"
    return gets.chomp.to_i
  end

  def game
    memory = []
    y = 0
    #puts "--------Please select a mode--------"
    #puts "1. One Player"
    #puts "2. Two Player"
    #puts "3. Best of 5"
    #puts "4. Infinite"
    while y != 9
      y = game_options
      if y != 9
        update_stats(generate_result(y, artificial_intelligence))
      end
    end
  end

  def game_one_player
    y = 0
    while y != 9
      y = game_options
      if y != 9
        update_stats(generate_result(y, artificial_intelligence))
      end
    end
  end

  def game_two_player
    system "clear" or system "cls"
  end

  def artificial_intelligence
    return rand(3) + 1
  end

  def valid_option(x)
    if (x > 4) || (x < 1)
      x = 4
    end
    #((x > 4) || (x < 1))? x = 4 end
    return x
  end

  def generate_result(y, a)
    puts "\n\n-----Results------"
    y = valid_option(y)
    a = valid_option(a)
    puts "#{player_name} threw #{@chart[y][0]}"
    puts "Player 2 threw #{@chart[0][a]}"
    return @chart[y][a]
  end

  def update_stats(x)
    if x == 1
      puts "--#{player_name} Wins!--"
      @wins_total += 1
      @current_win_streak += 1
      if @current_win_streak > @best_win_streak
        @best_win_streak += 1
      end
    elsif x == -1
      puts "--Player 2 Wins!--"
      @loss_total += 1
      @current_win_streak = 0
    else
      puts "----Its A Tie!----"
      @ties_total += 1
    end
    @games_played += 1
  end

#---------------------------DATABASE MANAGEMENT METHODS--------------------------#

  def display_login_menu
    puts "\n\n-------------Login Menu-------------"
    puts "Please enter your username:"
    name = gets.chomp.to_s
    load_game_record(name)
  end

  def open_game_database
    @db = SQLite3::Database.open "game.db"
    @db.execute "CREATE TABLE IF NOT EXISTS game_records(id INTEGER PRIMARY KEY, 
      name TEXT NOT NULL UNIQUE, games_played_count INT DEFAULT 0,
      win_count INT DEFAULT 0, loss_count INT DEFAULT 0, tie_count  INT DEFAULT 0,
      best_win_streak INT DEFAULT 0, current_win_streak INT DEFAULT 0);"
  end

  def close_game_database
    @db.close if db
  end

  def load_game_record user_name
    #db = SQLite3::Database.open "game.db"

    user_record = @db.execute( "select * from game_records where name = '#{user_name}'" )

    if user_record.empty?
      puts "entered user_record.empty?"
      @db.execute( "INSERT INTO game_records( name, games_played_count, win_count, loss_count, tie_count, best_win_streak, current_win_streak )
        VALUES('#{user_name}', 0, 0, 0, 0, 0, 0)" )
      puts "--New user #{user_name} has been created!--"
      reset_stats
    else
      @games_played = user_record[0][2]
      @wins_total = user_record[0][3]
      @loss_total = user_record[0][4]
      @ties_total = user_record[0][5]
      @best_win_streak = user_record[0][6]
      @current_win_streak = user_record[0][7]
      puts "----You have logged in as #{user_name}!----"
    end
    @player_name = user_name

    #@db.close if db
  end

  def save_game_record
    #db = SQLite3::Database.open "game.db"

    user_record = @db.execute( "select * from game_records where name = '#{@player_name}'" )

    if user_record.empty?
      @db.execute( "INSERT INTO game_records( name, games_played_count, win_count, loss_count, tie_count, best_win_streak, current_win_streak )
        VALUES('#{@player_name}', 0, 0, 0, 0, 0, 0)" )
      puts "New save data for #{@player_name} has been created"
    else
      @db.execute( "update game_records
        set games_played_count = #{@games_played},
            win_count = #{@wins_total},
            loss_count = #{@loss_total},
            tie_count = #{@ties_total},
            best_win_streak = #{@best_win_streak},
            current_win_streak = #{@current_win_streak}
        where name = '#{@player_name}'" )
      puts "Data for #{@player_name} has been saved"
    end

    #@db.close if db
  end

  def delete_current_user
    user_record = @db.execute( "select * from game_records where name = '#{@player_name}'" )
      if user_record.empty?
        puts "#{player_name} data does not exist"
      else
        db.execute( "DELETE FROM game_records
          WHERE name = #{player_name}" )
      end
  end
end

#puts rand(3) + 1
a = RockPaperScissors.new

#puts "Enter b"
#b = gets.chomp
#puts b
