module Hangman
  class Display
    class << self
      def draw_hangman(remaining_attempts)
        current_stage = Constants::HANGMAN_STAGES[Constants::TOTAL_ATTEMPTS - remaining_attempts]
        
        if remaining_attempts <= 2
          current_stage = current_stage.red.blink
        elsif remaining_attempts <= 4
          current_stage = current_stage.yellow
        end
        
        current_stage
      end

      def display_game_state(word, guessed_letters, remaining_attempts)
        system('clear') || system('cls')
        puts draw_hangman(remaining_attempts)
        puts "\nWord: #{mask_word(word, guessed_letters)}"
        puts "Guessed letters: #{guessed_letters.join(', ')}"
        puts "Remaining attempts: #{remaining_attempts}"
      end

      def mask_word(word, guessed_letters)
        word.chars.map { |char| guessed_letters.include?(char.downcase) ? char : '_' }.join(' ')
      end

      def display_victory_animation(word)
        3.times do
          system('clear') || system('cls')
          puts Constants::VICTORY_ASCII.green
          puts "\nThe word was: #{word}".green
          sleep(0.5)
          system('clear') || system('cls')
          puts Constants::VICTORY_ASCII.blue
          puts "\nThe word was: #{word}".blue
          sleep(0.5)
        end
        puts "\nCongratulations! You won!".green
      end

      def display_funny_fail(word)
        system('clear') || system('cls')
        funny_fail = Constants::FUNNY_FAILS.sample
        puts funny_fail.red
        puts "\nGame Over! The word was: #{word}".red
        sleep(1)
      end

      def display_scoreboard(scores)
        if scores.empty?
          puts "\nNo scores yet!".yellow
        else
          puts "\nScoreboard:".blue
          scores.each do |player, score|
            puts "#{player}: #{score['wins']}/#{score['total']} wins"
          end
        end
        puts "\nPress Enter to continue..."
        gets
      end
    end
  end
end
