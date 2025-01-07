module Hangman
  class SaveManager
    class << self
      def save_game_to_file(save_file, game)
        game_state = {
          player: game.current_player,
          word: game.word,
          guessed_letters: game.guessed_letters,
          remaining_attempts: game.remaining_attempts,
          timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S")
        }
        File.write(save_file, JSON.generate(game_state))
        puts "Game saved successfully!".green
      end
    end
  end
end
