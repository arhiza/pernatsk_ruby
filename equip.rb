#!/usr/bin/env ruby
# поиск оптимальной траты имеющихся ресурсов для возможного максимума эквипа

# ресурсы для закупа эквипа
$cash_cookie = 100 # печенье
$cash_peacocks = 100 # перья
$cash_dumbbells = 100 # гантели

# "вес" остатка ресов, для выбора лучших вариантов из найденных
# коэффициенты из курса в контрабанде, можно поменять на субъективные предпочтения
def weight(cookie,peacocks,dumbbells)
	return cookie+5*peacocks+6*dumbbells
end

count_res = 6 # количество результатов для просмотра, при 0 - показывать все найденные (может быть очень много)

# в результатах будет: общее количество дней, на сколько можно закупить эквипа
# количество крыльев за печенье/перья/гантели, аналогично для хвостов
# ресы, которые останутся после покупки

#####################################
# цены на эквип
$pr_wings_cookie = 10 # крылья за печенье
$pr_wings_peacocks = 2 # ...за перья
$pr_wings_dumbbells = 3 # ...за гантели
$pr_tail_cookie = 14 # хвост за печенье
$pr_tail_peacocks = 3 # ...за перья
$pr_tail_dumbbells = 4 # ...за гантели

max_w_c = $cash_cookie/$pr_wings_cookie
max_w_p = $cash_peacocks/$pr_wings_peacocks
max_w_d = $cash_dumbbells/$pr_wings_dumbbells

$max_equip = 0 # на сколько дней эквипа можно запасти
$finded_res = [] # найденные варианты для сравнения (count, w_c, w_p, w_d, t_c, t_p, t_d, rem_c, rem_p, rem_d)

# проверка, годится ли вариант
def check_variant(w_c, w_p, w_d, t_c, t_p, t_d)
	# крыльев должно быть столько же сколько хвостов
	if (w_c+w_p+w_d) != (t_c+t_p+t_d)
		return false
	end
	# ресурсов должно хватать на все
	rem_c = $cash_cookie - (w_c*$pr_wings_cookie + t_c*$pr_tail_cookie)
	if rem_c < 0
		return false
	end
	rem_p = $cash_peacocks - (w_p*$pr_wings_peacocks + t_p*$pr_tail_peacocks)
	if rem_p < 0
		return false
	end
	rem_d = $cash_dumbbells - (w_d*$pr_wings_dumbbells + t_d*$pr_tail_dumbbells)
	if rem_d < 0
		return false
	end
	# если получилось набрать эквипа больше, чем раньше, запоминаем вариант
	sum_equip = w_c+w_p+w_d
	if sum_equip >= $max_equip
		$finded_res << [sum_equip, w_c, w_p, w_d, t_c, t_p, t_d, rem_c, rem_p, rem_d]
		$max_equip = sum_equip
	end
	return true
end

# цикл по всем возможным количествам крыльев за печеньки
Array.new(max_w_c+1) { |o| o } .each do |w_c|
	t_c = ($cash_cookie - w_c*$pr_wings_cookie)/$pr_tail_cookie
	# остаток печенек на хвост
	[t_c,t_c-1].select { |o| o>=0 } .each do |t_c|
		w_p = $max_equip-w_c-max_w_d
		if w_p<0
			w_p=0
		end
		# цикл по всем возможным количествам крыльев за перья, исключая те, где общее количество до оптимального не дотянет
		Array.new(max_w_p+1-w_p) { |o| o=o+w_p } .each do |w_p|
			t_p = ($cash_peacocks - w_p*$pr_wings_peacocks)/$pr_tail_peacocks
			# остаток перьев на хвост
			[t_p,t_p-1].select { |o| o>=0 } .each do |t_p|
				w_d = $max_equip-w_c-w_p
				if w_d<0
					w_d=0
				end
				# цикл по всем возможным количествам крыльев за гантели, исключая те, где общее количество до оптимального не дотянет
				Array.new(max_w_d+1-w_d) { |o| o=o+w_d } .each do |w_d|
				#while w_d<=max_w_d
					t_d = ($cash_dumbbells - w_d*$pr_wings_dumbbells)/$pr_tail_dumbbells
					# остаток гантель на хвост
					[t_d,t_d-1].select { |o| o>=0 } .each do |t_d|
						check_variant(w_c, w_p, w_d, t_c, t_p, t_d)
					end
				#	w_d += 1
				end
			end
		end
	end
end


#$finded_res.each do |elem|
#	puts elem.join(" - ")
#end

$finded_res.delete_if { |elem| elem[0]<$max_equip} 
$finded_res = $finded_res.uniq { |elem| [elem[7],elem[8],elem[9]] }
$finded_res.sort_by! {| elem | -weight(elem[7],elem[8],elem[9]) }
if count_res>0
	$finded_res = $finded_res.slice(0, count_res)
end

puts "cookie = #{$cash_cookie}, peacocks = #{$cash_peacocks}, dumbbells = #{$cash_dumbbells}"
$finded_res.each do |elem|
	puts "days_all - #{elem[0]}, wings - [#{elem[1]}/#{elem[2]}/#{elem[3]}], tail - [#{elem[4]}/#{elem[5]}/#{elem[6]}], (#{elem[7]} cookie, #{elem[8]} peacocks, #{elem[9]} dumbbells)" # |#{weight(elem[7],elem[8],elem[9])}|"
end



