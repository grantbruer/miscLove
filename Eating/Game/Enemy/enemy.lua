function spawnEnemy()
	local size
	
	if player.width > 5000 then
		size = math.random(player.width,player.width*2) 
	else
		size = math.random(player.width/2,player.width*2.3)
	end
	
	local x = math.random(0,1)
	
	if x == 0 then
		x = map.x-map.width/2 - size*2
		xspeed = math.random(1,3)
	else
		x = map.x + map.width/2 + size*2
		xspeed = -math.random(1,3)
	end
	
	local y
	if size < map.height/2 then
		y = math.random(map.y-map.height/2 + (size), map.y+map.height/2 - (size)) --size*camera.xscale
	else
		y = math.random(map.y-map.height/2, map.y+map.height/2) --size*camera.xscale
	end
		local rand = math.random(1,8)
		local color
		if rand == 1 then
			color ={255,0,0}
		elseif rand == 2 then
			color ={0,255,0}
		elseif rand == 3 then
			color ={0,0,255}
		elseif rand == 4 then
			color ={255,255,0}
		elseif rand == 5 then
			color ={255,0,255}
		elseif rand == 6 then
			color ={0,255,255}
		elseif rand == 7 then
			color ={255,255,255}
		elseif rand == 8 then
			color = {0,0,0}
		end
		
	
	--local color = {math.random(1,4)*64-1,math.random(1,4)*64-1,math.random(1,4)*64-1}--{math.random(3,16)*16-1,math.random(3,16)*16-1,math.random(3,16)*16-1}

	local i = 1
	while i <=  #enemies do
		if enemies[i].width < size then
			break
		end
		i = i + 1
	end
	
	table.insert(enemies, i, {})
	--local n = #enemies
	
	enemies[i].x = x
	enemies[i].y = y
	enemies[i].width = size
	enemies[i].height = size
	enemies[i].xspeed = xspeed/camera.xscale
	enemies[i].color = color
	
end