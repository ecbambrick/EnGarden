math.absmin = function(a,b)
	if math.abs(a) < math.abs(b) then return a
	else 							  return b end
end

math.absmax = function(a,b)
	if math.abs(a) > math.abs(b) then return a
	else 							  return b end
end

math.clamp = function(val, minimum, maximum)
	if not maximum then
		maximum = minimum
		minimum = -minimum
	end
	if		val < minimum then return minimum
	elseif	val > maximum then return maximum
	else 					   return val end
end

math.sign = function(val)
	if		val >  0 then return 1
	elseif	val == 0 then return 0
	else				  return -1 end
end

math.within = function(val, min, max)
	if val >= min and val <= max then return true
	else return false end
end

math.between = function(val, min, max)
	if val > min and val < max then return true
	else return false end
end

math.round = function(x)
	return math.floor(x + 0.5)
end

table.contains = function(t, v)
	for i in pairs(t) do
		if t[i] == v then return true end
	end
	return false
end

table.removevalue = function(t, v)
	for i in pairs(t) do
		if t[i] == v then table.remove(t,i) end
	end
end

table.nilvalue = function(t, v)
	for i in pairs(t) do
		if t[i] == v then t[i] = nil end
	end
end
	
table.clear = function(t)
	for i in pairs(t) do
		t[i] = nil
	end
	t = nil
end

table.copy = function(t)
	local newTable = {}
	for i in pairs(t) do
		newTable[i] = t[i]
	end
	return newTable
end

table.insert_old = table.insert
table.insert = function(t, v)
	table.insert_old(t,v)
	return v
end
