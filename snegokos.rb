#!/usr/bin/env ruby

# массив-карта - 8х8, _ - пустая клетка (уже счищенный сугроб),
# 1 и 2 - сугробы (маленький и большой соответственно), Х - птица, D - лед.
karta = [[1,1,1,1,1,"D",1,2],
         [1,"D",1,1,1,1,1,1],
         [1,1,1,"D",1,1,"D",1],
         ["X",1,1,1,1,1,1,1],
         ["D",1,2,2,2,1,1,1],
         [1,1,"D",2,1,"D",1,"D"],
         [1,1,1,1,2,1,2,1],
         [2,1,2,"D",1,1,1,1]]

$go_moves = 10


def clon_karta(karta_etalon)
  karta_new = []
  karta_etalon.each do |elem|
    tmp = Array.new(elem)
    karta_new << tmp
  end
  karta_new
end
def show(karta_m)
  karta_m.each do |elem|
    puts elem.join(".")
  end
end

#show(karta)
#puts " "

def get_next_coord(x_col,x_row,direction)
  next_col = x_col
  next_row = x_row
  if direction == "N"
    next_row -= 1
  elsif direction == "S"
    next_row += 1
  elsif direction == "W"
    next_col -= 1
  else #"E"
    next_col += 1
  end
  is_OK = true
  if next_col == -1 || next_col == 8 || next_row == -1 || next_row == 8
    is_OK = false
  end
  {is_OK: is_OK, next_row: next_row, next_col: next_col}
end

def move_bird(karta_test,direction) #север N, юг S, запад W, восток E
  count_sneg = 0 #количество пройденных сугробов
  sum_medal = 0 #вес пройденных сугробов = количество набранных медальонов
  x_row = -1
  x_col = -1
  i = -1
  karta_test.each do |elem|
    i += 1
    ind = elem.index("X")
    if !(ind.nil?)
      x_col = ind
      x_row = i
    end
  end
  #puts "#{x_row},#{x_col}" #где там вообще птица?

  mm = get_next_coord(x_col,x_row,direction)
  is_move = true
  if mm[:is_OK] #за край поля не сваливаемся, значит надо проверить, не уткнемся ли сразу же в льдину
    cage = karta_test[mm[:next_row]][mm[:next_col]]
    #puts "#{direction}: go to #{cage}"
    if cage == "D"
      is_move = false
    else #место свободное и не на краю, значит все ок, двигаемся
      gogo = true
      while gogo
        if cage == 1
          count_sneg += 1
          sum_medal += 1
        elsif cage == 2
          count_sneg += 1
          sum_medal += 2
        end
        karta_test[x_row][x_col] = "_" #тут были, отсюда ушли
        x_row = mm[:next_row]
        x_col = mm[:next_col]
        karta_test[x_row][x_col] = "X" #сюда пришли
        mm = get_next_coord(x_col,x_row,direction) #проверяем, будем ли двигаться дальше
        if mm[:is_OK]
          cage = karta_test[mm[:next_row]][mm[:next_col]]
          if cage == "D"
            gogo = false
            sum_medal -= 1
          end
        else
          gogo = false
        end
      end
    end
  else
    is_move = false
    #puts "#{direction}: go to #{mm[:next_row]},#{mm[:next_col]} - #{mm[:is_OK]}"
  end
  {is_move: is_move, count_sneg: count_sneg, sum_medal: sum_medal}
end

$roots_res = [] #сюда маршруты складывать

def recurs_find(current_karta,number_move,count_sneg,sum_medal,txt_root)
  ["N","S","W","E"].each do |direction| #для каждого направления пытаемся сделать шаги
    karta_next = clon_karta(current_karta) #сделать клон, в котором будет следующий шаг
    #show(karta_next)
    inf = move_bird(karta_next,direction) #попытались перейти в заданном направлении
    if inf[:is_move] #если true, значит какой-то ход получился, и надо посчитать собранное и попытаться пойти дальше
      #puts "direction: #{direction}"
      #show(karta_next)
      if number_move<$go_moves
        #puts "   go next"
        recurs_find(karta_next,number_move+1,inf[:count_sneg]+count_sneg,inf[:sum_medal]+sum_medal,txt_root+direction)
      else
        $roots_res << [inf[:sum_medal]+sum_medal,inf[:count_sneg]+count_sneg,txt_root+direction]
      end
      #...
    #else
    #  puts "direction: #{direction} - fail move"
    end
    #puts " "
  end
end

recurs_find(karta,1,0,0,"")
puts "--------------"
show(karta)
puts " all_roots = #{$roots_res.count}"
max_medal = 0
$roots_res.each do |elem|
  #puts elem.join("-")
  if max_medal<elem[0]
    max_medal = elem[0]
  end
end
$roots_res.sort{|a,b| b[0]<=>a[0]}
puts " only best:"
$roots_res.each do |elem|
  if max_medal==elem[0]
    puts elem.join("-")
  end
end


#karta_1 = clon_karta(karta)
#show(karta_1)
#inf = move_bird(karta_1,"N")
#puts "N: #{inf[:is_move]} - sneg = #{inf[:count_sneg]}, medal = #{inf[:sum_medal]}"
#show(karta_1)
#puts "  "

#karta_2 = clon_karta(karta)
#show(karta_2)
#inf = move_bird(karta_2,"S")
#puts "S: #{inf[:is_move]} - sneg = #{inf[:count_sneg]}, medal = #{inf[:sum_medal]}"
#show(karta_2)
#puts "  "

#karta_3 = clon_karta(karta)
#show(karta_3)
#inf = move_bird(karta_3,"W")
#puts "W: #{inf[:is_move]} - sneg = #{inf[:count_sneg]}, medal = #{inf[:sum_medal]}"
#show(karta_3)
#puts "  "

#karta_4 = clon_karta(karta)
#show(karta_4)
#inf = move_bird(karta_4,"E")
#puts "E: #{inf[:is_move]} - sneg = #{inf[:count_sneg]}, medal = #{inf[:sum_medal]}"
#show(karta_4)
#puts "  "
