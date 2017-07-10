class Hangman
  attr_reader :guesser, :referee, :board

  def initialize(guesser: HumanPlayer.new, referee: ComputerPlayer.new)
    @guesser = guesser
    @referee = referee
    @board = board
  end

  def setup
    word = @referee.pick_secret_word
    @board = Array.new(word)
    @guesser.register_secret_length(word)
  end

  def take_turn
    guess = @guesser.guess
    @referee.check_guess(guess)
    update_board(guess)
    @guesser.handle_response(guess)
  end

  def update_board(guess)
    @referee.check_guess(guess).each do |idx|
      @board[idx] = guess
    end
  end

  def play
    setup
    until won?
      take_turn
    end
  end

  def won?
    return @board.all? {|el| el != nil}
  end


end

class HumanPlayer

  def guess
    p "please pick a letter"
    guess = gets.chomp
  end

  def register_secret_length(word)
    word
  end

  def handle_response(guess)
    if @referee.check_guess(guess).empty?
      p "#{guess} is not in the word."
    end
  end

end

class ComputerPlayer

attr_reader :dictionary

  def initialize(dictionary = File.readlines("dictionary.txt"))
    @dictionary = dictionary
    @guessed_letters = []
  end

  def pick_secret_word
    @secret_word = @dictionary.sample
    @secret_word.length
  end

  def check_guess(guess)
    matches = []
    if @secret_word.include?(guess)
      @secret_word.chars.each_with_index do |l, idx|
        if l == guess
          matches << idx
        end
      end
    end
    matches
  end

  def register_secret_length(word_length)
    @dictionary = @dictionary.reject {|word| word.length != word_length}
  end

  def possible_letters_hash
    @potential_letters = Hash.new(0)
    @dictionary.each do |word|
      word.chars do |letter|
        @potential_letters[letter] += 1
      end
    end
  end

  def guess(board)
    possible_letters_hash
    guess = nil
    letter_count = 0
    @potential_letters.each do |letter, count|
      if !@guessed_letters.include?(letter) &&
        count > letter_count &&
        !board.include?(letter)

        guess = letter
        letter_count = count
      end
    end
    @guessed_letters << guess

  guess
  end

  def handle_response(guess, index)
    words_to_delete = []
    if index.length > 0
      @dictionary = @dictionary.select {|word| word.include?(guess) && word.count(guess) == index.length}

      @dictionary.each do |word|
        index.each do |idx|
          if word[idx] != guess
            words_to_delete << word
          end
        end
      end

    else
      @dictionary = @dictionary.select {|word| !word.include?(guess)}
    end

    @dictionary = @dictionary.select {|word| !words_to_delete.include?(word)}
    @dictionary
  end


  def candidate_words
    @dictionary
  end

end

if $0 == __FILE__
  p "What is the guesser's name? or is the guesser the computer?"
  guesser = gets.chomp
  if guesser.downcase == "computer"
    player1 = ComputerPlayer.new
    player2 = HumanPlayer.new
  else
    player1 = HumanPlayer.new
    player2 = ComputerPlayer.new
  end
  new_game = Hangman.new(guesser: player1, referee: player2)
  new_game.play
end
