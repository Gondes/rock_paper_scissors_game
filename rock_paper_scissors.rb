#press ctrl-shift-b to run code
require './user'
require 'sqlite3'

class RockPaperScissors

  def initialize
    open_game_database
    generate_default_user
    generate_win_array
  end

  def start_up
    clear_screen
    menu
  end

  def generate_default_user
    @user1 = User.new
    @user1.name = "Player 1"
    @user1.reset_stats
    @user2 = User.new
    @user2.name = "Computer"
    @user2.reset_stats
  end

  def generate_win_array
    @chart = [["Chart", "Rock", "Paper", "Scissors", "Nothing"], ["Rock", 0, -1, 1, 1], ["Paper", 1, 0, -1, 1], ["Scissors", -1, 1, 0, 1], ["Nothing", -1, -1, -1, 0]]
    #print @chart
  end

  def display_menu_options
    puts "\n\n------Rock Paper Scissors Menu!------"
    puts "Hello #{@user1.name}!"
    puts "1. Start New Game"
    puts "2. Display Stats"
    puts "3. Reset Stats"
    puts "4. Save Stats"
    puts "5. Login"
    puts "6. Delete Current User"
    puts "9. Exit"
    puts "-----Please enter a valid number-----"
  end

  def menu
    i = 0

    until i.eql? 9
      display_menu_options
      i = gets.chomp.to_i
      case i
      when 1
        game
      when 2
        @user1.display_stats
      when 3
        @user1.reset_stats
        @user2.reset_stats
        puts "\n\n--------Stats have been reset--------"
      when 4
        save_stats(@user1)
      when 5
        display_login_menu(@user1)
      when 6
        delete_current_user
      when 9
        close_game_database
        clear_screen
        puts "Thank you for playing!\n\n"
      else
      end
    end
  end

  def save_stats(user)
    puts "Do you wish to save data for the user #{user.name}? (y/n)"
    if gets.chomp.to_s.eql? "y"
      save_game_record(user)
    else
      puts "Data for #{user.name} was not saved!"
    end
  end

  def clear_screen
    system "clear" or system "cls"
  end

#----------------------------------GAME LOGIC----------------------------------#

  def game_options player
    puts "\n\n---#{player.name} pick your hand!---"
    puts "1. Rock"
    puts "2. Paper"
    puts "3. Scisors"
    puts "9. Back"
    return gets.chomp.to_i
  end

  def display_game_menu
    puts "\n\n--------Please select a mode--------"
    puts "1. One Player"
    puts "2. Two Player"
    puts "9. Back"
  end

  def game
    memory = []
    i = 0
    while i != 9
      display_game_menu
      i = gets.chomp.to_i
      case i
      when 1
        game_one_player
      when 2
        game_two_player
      when 9
        #puts "\n\n----You have exited the game----"
      else
        puts "---Invalid Input---"
      end
    end
  end

  def game_one_player
    y = 0
    clear_screen
    while y != 9
      y = game_options(@user1)
      clear_screen
      (y == 9)? break :

      update_stats(generate_result(y, artificial_intelligence))
    end
  end

  def game_two_player
    puts "Please enter a second user to challenge."
    (!display_login_menu(@user2))? return : 

    p1 = 0
    clear_screen
    while p1 != 9
      p1 = game_options(@user1)
      clear_screen
      (p1 == 9)? break :

      p2 = game_options(@user2)
      clear_screen
      (p2 == 9)? break :

      update_stats(generate_result(p1, p2))
    end
    disconnect_user_2
  end

  def disconnect_user_2
    puts "Logging out of user #{@user2.name}"
    save_stats(@user2)

    @user2.name = "Computer"
    @user2.reset_stats
  end

  def artificial_intelligence
    return rand(3) + 1
  end

  def valid_option(x)
    ((x > 4) || (x < 1))? 4 : x
  end

  def generate_result(p1, p2)
    puts "\n\n-----Results------"
    p1 = valid_option(p1)
    p2 = valid_option(p2)
    puts "#{@user1.name} threw #{@chart[p1][0]}"
    puts "#{@user2.name} threw #{@chart[0][p2]}"
    return @chart[p1][p2]
  end
  def update_stats(x)
    if x == 1
      puts "--#{@user1.name} Wins!--"
      @user1.win
      @user2.lose
    elsif x == -1
      puts "--#{@user2.name} Wins!--"
      @user1.lose
      @user2.win
    else
      puts "----Its A Tie!----"
      @user1.tie
      @user2.tie
    end
  end

#---------------------------DATABASE MANAGEMENT METHODS--------------------------#

  def display_login_menu(user)
    puts "\n\n-------------Login Menu-------------"
    puts "Please enter your username:"
    name = gets.chomp.to_s
    if (name.eql? @user1.name) || (name.eql? @user2.name)
      puts "#{name} is alreadly logged on\nPlease try again later"
      false
    else
      load_game_record(name, user)
      true
    end
  end

  def open_game_database
    @db = SQLite3::Database.open "game.db"
    @db.execute "CREATE TABLE IF NOT EXISTS game_records(id INTEGER PRIMARY KEY, 
      name TEXT NOT NULL UNIQUE, games_played_count INT DEFAULT 0,
      win_count INT DEFAULT 0, loss_count INT DEFAULT 0, tie_count  INT DEFAULT 0,
      best_win_streak INT DEFAULT 0, current_win_streak INT DEFAULT 0, is_online INT DEFAULT 0);"
  end

  def close_game_database
    @db.close if @db
  end

  def load_game_record(user_name, user)
    user_record = @db.execute( "select * from game_records where name = '#{user_name}'" )

    if user_record.empty?
      @db.execute( "INSERT INTO game_records( name, games_played_count, win_count, loss_count, tie_count, best_win_streak, current_win_streak, is_online )
        VALUES('#{user_name}', 0, 0, 0, 0, 0, 0, 1)" )
      puts "--New user #{user_name} has been created!--"
      user.reset_stats
    else
      #if (@db.execute( "select is_online from game_records where name = '#{user_name}'")[0][0] == 0)
      user.games_played = user_record[0][2]
      user.wins_total = user_record[0][3]
      user.loss_total = user_record[0][4]
      user.ties_total = user_record[0][5]
      user.best_win_streak = user_record[0][6]
      user.current_win_streak = user_record[0][7]
      puts "----You have logged in as #{user_name}!----"
      #else
      #puts "#{user_name} is currently online\nPlease try again later"
    end
    user.name = user_name
  end

  def save_game_record(user)
    user_record = @db.execute( "select * from game_records where name = '#{user.name}'" )

    if user_record.empty?
      @db.execute( "INSERT INTO game_records( name, games_played_count, win_count, loss_count, tie_count, best_win_streak, current_win_streak )
        VALUES('#{user.name}', 0, 0, 0, 0, 0, 0)" )
      puts "New save data for #{user.name} has been created"
    else
      @db.execute( "update game_records
        set games_played_count = #{user.games_played},
            win_count = #{user.wins_total},
            loss_count = #{user.loss_total},
            tie_count = #{user.ties_total},
            best_win_streak = #{user.best_win_streak},
            current_win_streak = #{user.current_win_streak}
        where name = '#{user.name}'" )
      puts "Data for #{user.name} has been saved"
    end
  end

  def delete_current_user
    user_record = @db.execute( "select * from game_records where name = '#{@user1.name}'" )
    if user_record.empty?
      puts "Data for #{@user1.name} does not exist"
    else
      puts "Are you sure? (y/n)"
      if gets.chomp.to_s.eql? "y"
        @db.execute( "DELETE FROM game_records
          WHERE name = '#{@user1.name}'" )
        puts "---#{@user1.name} has been deleted!---"
      else
        puts "---Delete aborted---"
      end
    end
  end
end

a = RockPaperScissors.new
a.start_up
