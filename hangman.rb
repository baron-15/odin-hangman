require 'json'
$fname = "saved.txt"

class Hangman
    attr_accessor :answer, :guess, :guessCount

    def initialize(answer, guess, guessCount)
        @answer = answer
        @guess = guess
        @guessCount = guessCount
    end

    def to_json
        JSON.dump({
            :answer => @answer,
            :guess => @guess,
            :guessCount => @guessCount
        })
    end

    def self.from_json(string)
        data = JSON.load string
        self.new(data['answer'], data['guess'], data['guessCount'])
    end
end

def newWord()
    filename = "dictionary.txt"
    newfile = File.open(filename, "r")
    dictionary = newfile.map &:split
    newfile.close
    dictionaryCount = dictionary.count
    word = "abcdefghijklmn"
    until (word.length <= 12 && word.length >= 5)
        word = dictionary[rand(dictionaryCount)].join('')
    end
    wordArray = word.scan /\w/
    puts "Shhhh.... the answer is #{word}."
    return wordArray
end

def newGame()
    puts "New game (N) or load game (L) ?"
    input = gets.chomp
    if (input == "N")
        answer = newWord()
        guess = Array.new(answer.length, "_")
        guessCount = 0
        
    elsif (input == "L")
        loaded = readFile()
        answer = loaded.answer
        guess = loaded.guess
        guessCount = loaded.guessCount
        fileIntegrityCheck(answer, guess)
        puts "Shhhh.... per saved file, the answer is #{answer.join('')}."
    else
        puts "Invalid input."
        newGame()
    end
    printBoard(answer, guess, guessCount)
    nextMove(answer, guess, guessCount)
end

def fileIntegrityCheck(ans, gus)
    check = ans + gus
    check.each do |x|
        if x.length != 1
            failedIntegrity()
        end
    end
    ans.each do |x|
        unless lowerLetterCheck(x)
            failedIntegrity()
        end
    end

    gus.each_with_index do |x, index|
        unless (x == "_" || x == ans[index])
            failedIntegrity()
        end
    end
end

def lowerLetterCheck(x)
    code = x.ord
    if (x.length == 1 && code >=97 && code <= 122)
        return true
    else
        return false
    end
end

def failedIntegrity()
    puts "Integrity check failed."
    newGame()
end

def printBoard(a, g, c)
    printG = ""
    printN = ""
    g.each_with_index do |x, idx|
        printG << x
        printG << ' '
        printN << (idx+1).to_s
        printN << ' '
    end
    puts
    puts "Your current game is:"
    puts "#{printG}"
    puts "#{printN}"
    puts
    puts "Time for your next guess (a to z). Current number of wrong guesses: #{c}."
    puts "Wrong guesses allowed: 8."
end 

def nextMove(a, g, c) 
    continue = 0
    until (continue == 1)
        guessLetter = gets.chomp
        if lowerLetterCheck(guessLetter)
            continue = 1
        else
            puts "Invalid guess."
        end
    end

    match = 0
    a.each_with_index do |x, index|
        if guessLetter == x
            g[index] = x
            match += 1
        end
    end
    
    if match == 0
        puts "Incorrect guess!"
        c+=1
    else
        puts "Correct guess!"
    end

    printBoard(a, g, c)
    gameOver(a, g, c)
end

def gameOver(a, g, c)
    if a == g
        puts "You win! You are the man!"
        puts
        newGame()
    elsif c > 8
        puts "You lose! You made more than 8 wrong guesses!"
        puts
        newGame()
    else
        puts "Do you want to save the progress first(Y/N)?"
        saveProgressLetter = gets.chomp
        if (saveProgressLetter == "Y")
            saveFile(a, g, c)
            printBoard(a, g, c)
            nextMove(a, g, c)
        elsif (saveProgressLetter == "N")
            printBoard(a, g, c)
            nextMove(a, g, c)
        else
            puts "Invalid entry. Won't save. Now continue."
            printBoard(a, g, c)
            nextMove(a, g, c)
        end
    end
end

def readFile()
    puts "Reading file..."
    if File.exist?($fname)
        openFile = File.open($fname, "r")
        readContent = openFile.read
        content = Hangman.from_json(readContent)
        a = content.answer
        g = content.guess
        c = content.guessCount
    else
        puts "No saved.txt found."
        newGame()
    end
    load = Hangman.new(a, g, c)
    return load
end

def saveFile(a, g, c)
    saved = Hangman.new(a, g, c)
    saveJson = saved.to_json
    if(File.exist?($fname))
        puts "File exists. Do you want to overwrite (Y/N)?"
        input = gets.chomp
        if (input != "Y")
            puts "Ok. I won't overwrite."
            return
        end
        puts "Ok. I will overwrite it."
    end
    puts "Saving..."
    puts saveJson
    savedFile = File.new("saved.txt", "w")
    savedFile.puts saveJson
    savedFile.close
    puts "File saved."
end

newGame()