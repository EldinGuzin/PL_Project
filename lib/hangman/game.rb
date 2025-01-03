require 'tty-prompt'
require 'json'
require 'colorize'
require 'fileutils'
require 'launchy'

module Hangman
  class Game
    attr_reader :current_player, :word, :guessed_letters, :remaining_attempts, :scores

    def initialize
      @scores = load_scores
      @prompt = TTY::Prompt.new
      FileUtils.mkdir_p(Constants::SAVES_DIR) unless Dir.exist?(Constants::SAVES_DIR)
    end

    def start
      loop do
        choice = @prompt.select("Welcome to Hangman!", [
          "New Game",
          "Load Saved Game",
          "View Scoreboard",
          "Exit"
        ])

        case choice
        when "New Game"
          setup_new_game
        when "Load Saved Game"
          load_game_menu
        when "View Scoreboard"
          Display.display_scoreboard(@scores)
        when "Exit"
          break
        end
      end
    end

    private

    def setup_new_game
      game_mode = @prompt.select("Choose game mode:", ["Single Player", "Multiplayer"])
      @current_player = @prompt.ask("Enter your name:") { |q| q.required true }
      
      @word = if game_mode == "Single Player"
        get_random_word
      else
        player2 = @prompt.ask("Enter Player 2's name:") { |q| q.required true }
        get_word_from_player
      end

      @guessed_letters = []
      @remaining_attempts = Constants::TOTAL_ATTEMPTS
      play_game
    end

    def play_game
      until game_over?
        Display.display_game_state(@word, @guessed_letters, @remaining_attempts)
        action = @prompt.select("Choose action:", ["Guess Letter", "Save Game", "Exit"])
        
        case action
        when "Guess Letter"
          make_guess
        when "Save Game"
          save_game_menu
          break
        when "Exit"
          break
        end
      end

      display_game_result if game_over?
    end

    def save_game_menu
      save_options = [
        "Create new save",
        "Overwrite existing save",
        "Cancel"
      ]

      choice = @prompt.select("Save Game Options:", save_options)

      case choice
      when "Create new save"
        create_new_save
      when "Overwrite existing save"
        overwrite_existing_save
      end
    end

    def create_new_save
      save_name = @prompt.ask("Enter save name:") do |q|
        q.required true
        q.validate(/^[a-zA-Z0-9_-]+$/)
        q.messages[:valid?] = 'Save name can only contain letters, numbers, hyphens and underscores'
      end

      save_file = File.join(Constants::SAVES_DIR, "#{save_name}.json")
      
      if File.exist?(save_file)
        puts "Save file already exists!".red
        return
      end

      SaveManager.save_game_to_file(save_file, self)
    end

    def overwrite_existing_save
      saves = list_save_files
      
      if saves.empty?
        puts "No save files found!".red
        return
      end

      choices = saves.map do |save_file|
        save_data = JSON.parse(File.read(File.join(Constants::SAVES_DIR, save_file)))
        display_name = "#{File.basename(save_file, '.json')} " +
                      "(Player: #{save_data['player']}, " +
                      "Progress: #{save_data['guessed_letters'].length} guesses, " +
                      "Saved: #{save_data['timestamp']})"
        { name: display_name, value: save_file }
      end

      choices << { name: "Cancel", value: "Cancel" }

      save_choice = @prompt.select("Choose save to overwrite:", choices)
      return if save_choice == "Cancel"

      save_file = File.join(Constants::SAVES_DIR, save_choice)
      SaveManager.save_game_to_file(save_file, self)
    end

    def load_game_menu
      saves = list_save_files
      
      if saves.empty?
        puts "No save files found!".red
        return
      end

      choices = saves.map do |save_file|
        save_data = JSON.parse(File.read(File.join(Constants::SAVES_DIR, save_file)))
        display_name = "#{File.basename(save_file, '.json')} " +
                      "(Player: #{save_data['player']}, " +
                      "Progress: #{save_data['guessed_letters'].length} guesses, " +
                      "Saved: #{save_data['timestamp']})"
        { name: display_name, value: save_file }
      end

      choices << { name: "Cancel", value: "Cancel" }
      
      choice = @prompt.select("Choose a save file to load:", choices)
      return if choice == "Cancel"

      load_game_from_file(File.join(Constants::SAVES_DIR, choice))
    end

    def list_save_files
      Dir.glob(File.join(Constants::SAVES_DIR, "*.json"))
         .select { |f| File.file?(f) }
         .map { |f| File.basename(f) }
    end

    def load_game_from_file(save_file)
      return puts "Save file not found!".red unless File.exist?(save_file)

      game_state = JSON.parse(File.read(save_file))
      @current_player = game_state['player']
      @word = game_state['word']
      @guessed_letters = game_state['guessed_letters']
      @remaining_attempts = game_state['remaining_attempts']
      play_game
    end

    def make_guess
      guess = @prompt.ask("Enter a letter:") do |q|
        q.validate /^[a-zA-Z]$/
        q.messages[:valid?] = 'Please enter a single letter'
      end

      guess.downcase!
      if @guessed_letters.include?(guess)
        puts ["Already tried that one! 🤦", 
              "Having memory issues? 😜", 
              "That letter looks familiar... 🤔"].sample.red
        sleep(1)
        return
      end

      @guessed_letters << guess
      unless @word.include?(guess)
        @remaining_attempts -= 1
        puts ["What a miss! ⚾", 
              "Not even close! 🎯", 
              "Better luck next time! 🍀",
              "Did you just guess randomly? 🎲"].sample.red
        sleep(0.8)
      else
        puts ["Good one! 🎯", 
              "Nice guess! 🌟", 
              "You're on fire! 🔥"].sample.green
        sleep(0.5)
      end
    end

    def game_over?
      word_guessed? || @remaining_attempts.zero?
    end

    def word_guessed?
      @word.chars.all? { |char| @guessed_letters.include?(char.downcase) }
    end

    def display_game_result
      if word_guessed?
        Display.display_victory_animation(@word)
      else
        Display.display_funny_fail(@word)
        open_random_video if prompt_for_video
      end
      puts "\nPress Enter to continue..."
      gets
      update_score(word_guessed?)
    end

    def prompt_for_video
      choice = @prompt.select("Want to see something funny? (Warning: Opens web browser)", ["Yes", "No"])
      choice == "Yes"
    end

    def open_random_video
      Launchy.open(Constants::FUNNY_VIDEOS.sample)
    end

    def update_score(won)
      @scores[@current_player] = { 'wins' => 0, 'total' => 0 } unless @scores[@current_player]
      @scores[@current_player]['wins'] += 1 if won
      @scores[@current_player]['total'] += 1
      save_scores
    end

    def load_scores
      return {} unless File.exist?(Constants::SCORES_FILE)
      JSON.parse(File.read(Constants::SCORES_FILE))
    rescue JSON::ParserError
      {}
    end

    def save_scores
      File.write(Constants::SCORES_FILE, JSON.generate(@scores))
    end

    def get_random_word
      words = %w[programming ruby developer software engineer computer]
      words.sample.downcase
    end

    def get_word_from_player
      @prompt.mask("Enter the word for Player 2 to guess:") do |q|
        q.validate { |word| word.length >= 5 }
        q.messages[:valid?] = 'Word must be at least 5 characters long'
      end.downcase
    end
  end
end
