module Hangman
  module Constants
    TOTAL_ATTEMPTS = 6
    SAVES_DIR = 'saves'
    SCORES_FILE = 'scores.json'
    
    FUNNY_FAILS = [
      """
           +---+
           |   |
           O   |  
          /|\\  |   oops
         _/ \\  |  
          ||   |    
        ==========""",
      """
           +---+
           |   |
           O   |  help!
          /|\\  |   
           |   | /\\  
          / \\  |/  \\
        ==========""",
      """
           +---+
           |   |
           O   |  
          /|\\  |    zzz
          / \\  |    
         _____/|\\___
        ==========""",
    ]

    VICTORY_ASCII = """
      \\O/   YOU
       |    WON!
      / \\   
    """

    FUNNY_VIDEOS = [
      "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "https://www.youtube.com/watch?v=ZZ5LpwO-An4"
    ]

    HANGMAN_STAGES = [
      """
           +---+
           |   |
               |
               |
               |
               |
        ==========""",
      """
           +---+
           |   |
           O   |
               |
               |
               |
        ==========""",
      """
           +---+
           |   |
           O   |
           |   |
               |
               |
        ==========""",
      """
           +---+
           |   |
           O   |
          /|   |
               |
               |
        ==========""",
      """
           +---+
           |   |
           O   |
          /|\\  |
               |
               |
        ==========""",
      """
           +---+
           |   |
           O   |
          /|\\  |
          /    |
               |
        ==========""",
      """
           +---+
           |   |
           O   |   help!!
          /|\\  |
          / \\  |
               |
        =========="""
    ]
  end
end
