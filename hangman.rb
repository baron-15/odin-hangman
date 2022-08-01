filename = "dictionary.txt"
file = File.open(filename, "r")
dictionary = file.map &:split
dictionaryCount = dictionary.count
answer = "xxxxxxxxxxxxx"
until (answer.length <= 12 && answer.length >= 5)
    answer = dictionary[rand(dictionaryCount)].join('')
end
puts answer

