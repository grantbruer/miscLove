grant = {}
grant.table = {}

function tabletostring(list)
	local str="{"
	
	first = true
	for i,v in pairs(list) do
		if first then
			if type(i) == "string" then
				str = str .. "['" .. i .. "'] = "
			end
			if type(v) == "string" then
				str = str ..  "'" .. tostring(v) .. "'"
			elseif type(v) == "number" then
				str = str ..  tostring(v)
			elseif type(v) == "table" then
				str = str ..  tabletostring(v)
			end
			first = false
		else 
			if type(i) == "string" then
				if type(v) == "table" then
					str = str .. ", ['" .. i .. "'] = " ..  tabletostring(v)
				elseif type(v) == "number" then
					str = str .. ", ['" .. i .. "'] = " .. tostring(v)
				elseif type(v) == "table" then
					str = str .. ", ['" .. i .. "'] = " .. tabletostring(v)
				elseif type(v) == "string" then
					str = str .. ", ['" .. i .. "'] = " .. "'" .. tostring(v) .. "'"
				end
			elseif type(i) == "number" then
				if type(v) == "table" then
					str = str .. ", " .. tabletostring(v)
				elseif type(v) == "number" then
					str = str .. ", " .. tostring(v)
				elseif type(v) == "table" then
					str = str .. ", " .. tabletostring(v)
				elseif type(v) == "string" then
					str = str .. ", " .. "'" .. tostring(v) .. "'"
				end
			end
			first = false
		end
	end
	
	str = str .. "}"
	return str
end

function stringtotable(str, start, stop)
	local list = {}
	local start = start or 1
	local stop = stop or string.len(str)
	local key = false
	
	local index = string.find(str, "{", start)
	local done = false
	index = index + 1 
	while not done and index < stop do		
	
		while string.sub(str,index,index) == " " and index < stop do
			index = index + 1
		end
		
		local first = index
		if string.sub(str,first,first) == "'" or string.sub(str, first, first) == '"' then
			index = index + 1
			local waitfor = string.sub(str,first,first)
			while string.sub(str,index,index) ~= waitfor and index < stop do
				index = index + 1
			end
			
			if key then
				list[key] = string.sub(str, first+1, index-1)
				key = false
			else
				table.insert(list,string.sub(str, first+1, index-1))
			end
		elseif tonumber(string.sub(str, first, first)) ~= nil then
			while tonumber(string.sub(str,index,index)) ~= nil and index < stop do
				index = index + 1
			end
			index = index - 1
			if key then
				list[key] = tonumber(string.sub(str, first, index))
				key = false
			else
				table.insert(list,tonumber(string.sub(str, first, index)))	
			end
		elseif string.sub(str, first, first) == "{" then
			local tablestarts = 1
			local tablestops = 0
			index = first + 1
			while tablestarts ~= tablestops and index < stop do
				if string.sub(str, index, index) =="{" then
					tablestarts = tablestarts + 1
				elseif string.sub(str, index, index) == "}" then
					tablestops = tablestops + 1
				end
				index = index + 1
			end
			index = index -1
			if key then
				list[key] = stringtotable(str, first, index)
				key = false			
			else
				table.insert(list, stringtotable(str, first, index))
			end
			
		elseif tonumber(string.sub(str, first, first)) == nil then
			if string.sub(str, first, first) == "[" then
				while string.sub(str,index,index) ~= "'" and string.sub(str,index,index) ~= '"' and index < stop do
					index = index + 1
				end
				if string.sub(str,index,index) == "'" then
					waitfor = "'"
				else
					waitfor = '"'
				end
				
				index = index + 1
				first = index
				
				while string.sub(str,index,index) ~= waitfor and index < stop do
					index = index + 1
				end
				
				
				index = index - 1				
				key = string.sub(str, first, index)
				
				while string.sub(str,index,index) ~= "=" and index < stop do
					index = index + 1
				end
				
			else
				while string.sub(str,index,index) ~= " " and string.sub(str, index,index) ~= "=" and index < stop do
					index = index + 1
				end
				index = index - 1
				key = string.sub(str, first, index)
				
				while string.sub(str,index,index) ~= "=" and index < stop do
					index = index + 1
				end
			end
			
		end
		
		index = index + 1
		
		while string.sub(str,index,index) == " " or string.sub(str, index,index) == "," or string.sub(str, index, index) == "}" and index < stop do
			index = index + 1
		end
		
		if index >= stop then
			done = true
		end	
	end
	return list
end




function grant.table.load(filename)
	local body= love.filesystem.isFile( filename )
	
	if not body then error("File Does Not Exist") end
	
	local contents, size = love.filesystem.read(filename, all )
	return contents
end




function grant.table.save(tab, filename)

	file = love.filesystem.newFile(filename)
	love.filesystem.write( filename, tabletostring(tab) , all)

end




