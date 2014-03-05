puts "How old are you?"
age = gets.chomp

age = age.to_i

[10,20,30, 40, 50].each do |n|
  puts "In #{n} years, you'll be #{age + n}"
end
