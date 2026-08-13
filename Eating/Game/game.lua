








function math.round(n, round)
	local d = n/round
	if d - math.floor(d) >=  0.5 then
		n = round * (math.floor(d) + 1)
	else
		n = round * math.floor(d)
	end
	return n
end



game = {}

function game.load()

	function love.keypressed(key)
		if key =='escape' then
			love.event.quit()
		elseif key == "y" then
			love.window.setFullscreen(not love.window.getFullscreen(), "exclusive")
		elseif key == "f" then
			myfps = not myfps
		elseif key == 'c' then
			clearscreen = not clearscreen
		elseif key == 'p' or key == ' ' then
			paused = not paused
			if not player.alive then
				player.alive = true
				game.reload()
			end
		elseif key == '[' then
			camera.zoom(0.5,0.5,true)	
		elseif key == ']' then
			camera.zoom(2,2,true)	
		elseif key == 'h' then
			camerainfo = not camerainfo
			mapinfo = not mapinfo
			playerinfo = not playerinfo
		elseif key ==';' then
			scale = scale/2
		elseif key == "'" then
			scale = scale*2
		elseif key =="i" then
			invincible = not invincible
		elseif key == 'u' then
			hideMoveCircles = not hideMoveCircles
		end
		
	end
	function love.mousepressed(x,y, button)
		if x > WINDOWWIDTH/2-156 and x < WINDOWWIDTH/2 + 144 and y > WINDOWHEIGHT/2 - 52 and y < WINDOWHEIGHT/2 + 48 then
			paused = false
			if not player.alive then
				player.alive = true
				game.reload()
			end
		end

		if love.system.getOS() ~= 'Android' then
			touch.id = 1
			touch.x = x
			touch.y = y
		end 
	end

	function love.mousereleased( id, x, y, pressure )
		if love.system.getOS() ~= 'Android' then
			touch.id = 0
			--touch.x = 0
			--touch.y = 0
		end 
	end

	function love.touchpressed( id, x, y, pressure )
		touch.id = id
		touch.x = x
		touch.y = y
		addOrUpdateTouch(touches,id,x,y)
	end

	function love.touchmoved( id, x, y, pressure )
		addOrUpdateTouch(touches,id,x,y)
		if touch.id == id then
			touch.x = x
			touch.y = y
		end
	end

	function love.touchreleased( id, x, y, pressure )
		removeTouch(touches,id)
		if touch.id == id then
			touch.id = 0
			if #touches > 0 then
				local t = touches[1]
				touch.id = t.id
				touch.x = t.x
				touch.y = t.y
			end
			--touch.x = 0
			--touch.y = 0
		end
	end

	touches = {}
	function addOrUpdateTouch(array,id,x,y)
		for i=1,#array do
			if array[i].id == id then
				array[i].x = x
				array[i].y = y
				return
			end
		end
		table.insert(array,{id=id,x=x,y=y})
	end

	function removeTouch(array,id)
		for i=1,#array do
			if array[i].id == id then
				table.remove(array,i)
				break
			end
		end
	end


	smallFont = love.graphics.newFont("Assets/Fonts/FreeSansBold.ttf",20*90/140)
	scoreFont = love.graphics.newFont("Assets/Fonts/FreeSansBold.ttf",24*96/140)
	moneyFont = love.graphics.newFont("Assets/Fonts/FreeSansBold.ttf",30*96/140)
	basicFont = love.graphics.newFont("Assets/Fonts/FreeSansBold.ttf",48*96/140)
	giantFont = love.graphics.newFont("Assets/Fonts/FreeSansBold.ttf",110*96/140)
	largeFont = love.graphics.newFont("Assets/Fonts/FreeSansBold.ttf",96)
	
	defaultFont = love.graphics.newFont(14)
	giantDefaultFont = love.graphics.newFont(110*96/140)

	
	player = {x = 400, y = 400,minsize = 10,maxsize = 80, width = 20, speed = 500, touchingenemy = false, color={255,255,255}, cubeseaten = 0, score = 1,highscore = 1, basewidth = 0, biggestwidth = 10, alive = true, timealive = 0, invincible = false, won = false, image = love.graphics.newImage("Assets/Images/cell.png"), cells = 1, cellwidth = 20}
	cellsize = 25
	
	player.imagewidth = player.image:getWidth()
	player.imageheight = player.image:getHeight()
	player.heightproportion = 1 --player.imageheight/player.imagewidth
	player.height = player.width * player.heightproportion
	
	enemies = {}--{x = 100, y = 100, width = 32, height = 32, speed = 5}
	
	level = {number = 3, win = 70}
	
	clearscreen = true
	paused = true
	
	WINDOWWIDTH = love.graphics.getWidth()
	WINDOWHEIGHT = love.graphics.getHeight()
	
	ENEMYSPAWNRATE = 5^-1
	enemyspawnrate = 0
	maxenemies = 30
	
	enemypic = love.graphics.newImage("Assets/Images/eyebrows.png")
	enemysadpic = love.graphics.newImage("Assets/Images/sad.png")
	enemypicwidth = enemypic:getWidth()

	backgroundimage = love.graphics.newImage("Assets/Images/lines.png")
	
	tile = {}
	tile.image = love.graphics.newImage('Assets/Images/grass.png')
	tile.imagewidth = tile.image:getWidth()
	tile.imageheight = tile.image:getHeight()
	tile.width = tile.imagewidth * 3
	tile.height = tile.imageheight * 3
	
	flowerpics = {love.graphics.newImage('Assets/Images/Flowers/flower-pink.png'), love.graphics.newImage('Assets/Images/Flowers/flower-black.png'),love.graphics.newImage('Assets/Images/Flowers/flower-green.png'),love.graphics.newImage('Assets/Images/Flowers/flower-purple.png')}
	
	originalflowersize = flowerpics[1]:getWidth()
	flowersize =  originalflowersize * 3
	
	hud = {width = WINDOWWIDTH, height = 120}
	
	camera.initialize(WINDOWWIDTH/2, (WINDOWHEIGHT-hud.height)/2 + hud.height, WINDOWWIDTH, (WINDOWHEIGHT -hud.height))

	scale = 1
	camerainfo = true
	mapinfo = true
	playerinfo = true
	
	map = {width = WINDOWWIDTH*8, height = (WINDOWHEIGHT -hud.height) * 8, x = WINDOWWIDTH/2, y = (WINDOWHEIGHT-hud.height)/2 + hud.height}
	
	player.x = map.x + map.width/2 - player.speed*3
	player.y = player.speed*3


	flowernumber = 10
	flowers = {}
	math.randomseed(123)
	for i = 1, flowernumber do
		local x = math.random(map.x - map.width/2, map.x + map.width/2 - flowersize/2)
		local y = math.random(map.y - map.height/2, map.y + map.height/2 - flowersize/2)
		local pic = math.random(1, #flowerpics)
		local rot = math.random(0, 2*math.pi)
		
		
		for i,v in pairs(flowers) do
			while (x-v[1])^2 + (y-v[2])^2 < flowersize/5 do
				x = math.random(map.x - map.width/2, map.x + map.width/2 - flowersize/2)
				y = math.random(map.y - map.height/2, map.y + map.height/2 - flowersize/2)
			end
		end
		
		
		table.insert(flowers, {x, y, pic, rot} )
		
		
		
		
	end
	
	math.randomseed(os.time())
	
	
	if (player.x - camera.width/2) > (map.x-map.width/2) and (player.x + camera.width/2) < (map.x + map.width/2) then
		camera.x = player.x
	end
	
	if (player.y - camera.height/2) > (map.y-map.height/2) and (player.y + camera.height/2) < (map.y + map.height/2) then
		camera.y = player.y
	end
		
	touch = {id=0, x=0,y=0}
	moveCircleRight = {x=WINDOWWIDTH*0.75, y = (WINDOWHEIGHT-hud.height)*0.75 + hud.height, radius = 180}
	moveCircleLeft = {x=WINDOWWIDTH*0.25, y = (WINDOWHEIGHT-hud.height)*0.75 + hud.height, radius = 180}

	hideMoveCircles = love.system.getOS() ~= 'Android'

	-- FPS cap
	min_dt = 1/60
	next_time = love.timer.getTime()
end

function game.distanceSquared(a,b)
	return (a.x-b.x)^2 + (a.y-b.y)^2
end

function game.getPlayerDirection()
	local angle
	local power
	if touch.id ~= 0 then --and game.distanceSquared(touch,moveCircle) < moveCircle.radius*moveCircle.radius then
		if touch.x < WINDOWWIDTH/2 then
			cx, cy, cr = moveCircleLeft.x, moveCircleLeft.y, moveCircleLeft.radius
		else
			cx, cy, cr = moveCircleRight.x, moveCircleRight.y, moveCircleRight.radius
		end
		angle = math.atan2(touch.y-cy, touch.x-cx)
		power = ((touch.y-cy)^2 + (touch.x-cx)^2)/(cr^2)

		--Zone Movement------------------------------
		--8 zones of movement, decided based on angle
		--1 is to the right and the number increased going clockwise
		--[[
		local worldx,worldy = getWorldPoint(touch.x,touch.y)

		local angle = math.atan2(worldy-player.y,worldx-player.x)

		local zone = math.floor( (angle + math.pi/8) / (math.pi/4), 1) % 8 + 1

		return unpack(directionMap[zone])
		--]]

		--[[
		--Terrible Movement--------------------------
		if worldx < player.x then
			h = 'left'
		else
			h = 'right'
		end

		if worldy < player.y then
			v = 'up'
		else
			v = 'down'
		end
		--]]
	else
		if love.keyboard.isDown("left") or love.keyboard.isDown('a') then
			angle = math.pi
		elseif love.keyboard.isDown("right") or love.keyboard.isDown('d') then
			angle = 0
		end

		if love.keyboard.isDown("up") or love.keyboard.isDown('w') then
			if angle == 0 then
				angle = -math.pi/4
			elseif angle == math.pi then
				angle = math.pi*5/4
			else
				angle = -math.pi/2
			end
		elseif love.keyboard.isDown("down") or love.keyboard.isDown('s') then
			if angle == 0 then
				angle = math.pi/4
			elseif angle == math.pi then
				angle = math.pi*3/4
			else
				angle = math.pi/2
			end
		elseif angle == nil then
			angle = 0
			power = 0
		end

		power = power or 1
	end
	return angle,math.min(power,1)
end

function game.update(dt)
	
	--  FPS cap
	next_time = next_time + min_dt
	
	if not paused then
		if player.score <= 0 and not invincible then
			player.alive = false
			paused = true
		end

		if love.system.getOS() ~= 'Android' then
			if touch.id == 1 then
				touch.x, touch.y = love.mouse.getPosition()
			end
		end 

		local angle,power = game.getPlayerDirection(player)
		local speed = player.speed*power
		player.x = player.x + dt*speed*math.cos(angle)/camera.xscale
		player.y = player.y + dt*speed*math.sin(angle)/camera.yscale

		if player.y + player.height/2 > map.y + map.height/2 then
			player.y = map.y+ map.height/2 - player.height/2
		elseif player.y-player.height/2 < map.y - map.height/2 then
			player.y = map.y - map.height/2 + player.height/2
		end

		--terrible Move System----------------------------
		--[[
		horizontal,vertical = game.getPlayerDirection(player)
		if (horizontal == 'left') and player.x -player.width/2 > map.x - map.width/2 then
			player.x = player.x -player.speed/camera.xscale
		end
		
		if ( horizontal == 'right' ) and player.x + player.width/2 < map.x + map.width/2 then
			player.x = player.x + player.speed/camera.xscale
		end
		
		if ( vertical == 'up' ) and player.y-player.height/2 > map.y - map.height/2 then
			player.y = player.y -player.speed/camera.xscale
		elseif player.y-player.height/2 < map.y - map.height/2 then
			player.y = map.y - map.height/2 + player.height/2
		end
		
		if  ( vertical == 'down' ) and player.y + player.height/2  < map.y+ map.height/2 then
			player.y = player.y + player.speed/camera.xscale
		elseif player.y + player.height/2 > map.y + map.height/2 then
			player.y = map.y+ map.height/2 - player.height/2
		end

		player.horizontal, player.vertical = horizontal,vertical
		--]]
		
		player.touchingenemy = false
		
		for i,v in pairs(enemies) do
			if v.destroy then
				table.remove(enemies, i)
			end
			
			if collision.circles(v.x,v.y,v.width/2, player.x, player.y, player.width/2) then --collision.rectangles(v.x-v.width/2,v.y-v.height/2,v.width,v.height, player.x-player.width/2, player.y-player.height/2, player.width, player.height) then
				if player.width > v.width then
				
				
					if v.width * camera.xscale < (player.width*camera.xscale)/2 then
						v.destroy = true
						player.cubeseaten = player.cubeseaten + 1
						player.score = player.score + v.width/10
						if player.width > player.basewidth then
							player.basewidth = player.basewidth + (v.width/player.width)/5
						end
						
						local prop = (v.width/(player.width+v.width) )
						local inprop = 1 - prop
						
						player.width = (player.width*camera.xscale + prop*8)/camera.xscale + 2
						if player.width > player.biggestwidth then
							player.biggestwidth = player.width
						end
						player.height = player.width * player.heightproportion
						
						
						
						player.color = { math.round(player.color[1]*0.8 + v.color[1]*0.2,32)-1, math.round(player.color[2]*0.8 + v.color[2]*0.2, 32)-1, math.round(player.color[3]*0.8 + v.color[3]*0.2,32)-1}
						for i,v in pairs(player.color) do
							if v > 255 then
								v = 255 
							elseif v < 0 then
								v = 0
							end
						end						
					else
						v.width = (v.width*camera.xscale - 1)/camera.xscale
						v.height = v.width
						player.width = player.width + 0.3/camera.xscale
						player.height = player.width * player.heightproportion
					end
			
					
					
					
					--[[if #enemies < maxenemies then	
						spawnEnemy()
					end]]
					
				else
					if player.width*camera.xscale > 15 then
						player.width = (player.width*camera.xscale - 1)/camera.xscale - 1
					end
					player.touchingenemy = true		
					v.width = v.width - math.random(2,6)/2
					v.height = v.width
					
					player.score = player.score - (v.width - player.width)*dt*10
					
				end
			end
			player.height = player.width * player.heightproportion
			
			v.x = v.x + v.xspeed
			
			if v.xspeed > 0 and v.x > map.x + map.width/2  + v.width then
				v.destroy = true
			elseif v.xspeed < 0  and v.x < map.x - map.width/2 - v.width then
				v.destroy = true
			end
			
		end
		
		if player.x - player.width/2 < map.x - map.width/2 then
			player.x = map.x - map.width/2 + player.width/2
		elseif player.x + player.width/2 > map.x + map.width/2 then
			player.x = map.x + map.width/2 - player.width/2
		elseif player.y - player.height/2 < map.y - map.height/2 then
			player.y = map.y - map.height/2 + player.height/2
		elseif player.y + player.height/2 > map.y + map.height/2 then
			player.y = map.y + map.height/2 - player.height/2
		end
		
		enemyspawnrate = enemyspawnrate + dt
		
		if enemyspawnrate >= ENEMYSPAWNRATE then
			enemyspawnrate = 0
		
			spawnEnemy()
		end
		
		
		player.score = player.score + (player.width-player.basewidth-5)*0.03
		
		if player.score > player.highscore then
			player.highscore = player.score
		end
		
		if player.score < 0 then player.score = 0 end
		
		--[[
		if (player.width*camera.xscale) < player.minsize and camera.targetzoom <= camera.xscale then        --player.width * camera.xscale > 50 then
			camera.zoom( ((player.minsize+player.maxsize)/2)/(player.width*camera.xscale), true) 
		elseif(player.width*camera.xscale) > player.maxsize and camera.targetzoom >= camera.xscale then
			camera.zoom(  ((player.minsize+player.maxsize)/2)/(player.width*camera.xscale), true) 
		end
		camera.updatezoom()
		]]
		player.basewidth = player.basewidth + 0.005
		player.timealive = player.timealive + dt
		
		
		
		if camera.zooming then
			camera.updatezoom()	
		elseif player.width*camera.xscale > level.win and camera.width < map.width then
			camera.zoom(0.5,0.5, true)--camera.zoom( (20*camera.xscale)/(level.win), true)
			level.number = level.number + 1
		elseif player.width*camera.xscale < 25 then
			camera.zoom(2,2, true)
			level.number = level.number - 1
		end
		--if not camera.zooming then
		if (player.x - camera.width/2) > (map.x-map.width/2) and (player.x + camera.width/2) < (map.x + map.width/2) then
			camera.x = player.x
		end
		
		if (player.y - camera.height/2) > (map.y-map.height/2) and (player.y + camera.height/2) < (map.y + map.height/2) then
			camera.y = player.y
		end
			
			--[[
			camera.onedge = false
			if (player.x - camera.width/2) <= (map.x-map.width/2) or (player.x + camera.width/2) >= (map.x + map.width/2) then
				camera.onedge = 'horizontal'
			end
			
			if (player.y - camera.height/2) <= (map.y-map.height/2) or (player.y + camera.height/2) >= (map.y + map.height/2) then
				if camera.onedge == 'horizontal' then
					camera.onedge = 'both'
				else
					camera.onedge = 'vertical'
				end
			end]]
		--end
		
	end -- of not paused
	
	if love.keyboard.isDown('-') then
		if player.width * camera.xscale - 1/camera.xscale > 10 then
			player.width = player.width - 1/camera.xscale
			player.height = player.width * player.heightproportion
		end
	elseif love.keyboard.isDown('=') then
		player.width = player.width + 1/camera.xscale
		player.height = player.width * player.heightproportion
	end
	
	if player.height*3 > map.height then
		map.width = map.width*8
		map.height = map.height*8
	end
	
	if player.width >=  cellsize * player.cells then
		player.cells = player.cells + 0
	end
	
end

function getWorldPoint(screenx,screeny)
	--screenx-(camera.x-camera.width/2) + map.x - camera.x

	local x = screenx/(camera.xscale*scale)+(camera.x-camera.width/2)
	local y = (screeny-hud.height)/(camera.yscale*scale) + (camera.y-camera.height/2)
	return x,y
end

function getScreenPoint(worldx,worldy)

	----worldx-(camera.x-camera.width/2)


	return (worldx-(camera.x-camera.width/2)), (worldy-(camera.y-camera.height/2))
end

function game.draw()

	
	love.graphics.push()
	
	love.graphics.translate(WINDOWWIDTH/2, (WINDOWHEIGHT-hud.height)/2 + hud.height)
	love.graphics.scale(camera.xscale*scale, camera.yscale*scale)
	love.graphics.translate(-WINDOWWIDTH/2, -(WINDOWHEIGHT-hud.height)/2 - hud.height)
	
	
	
	love.graphics.translate(map.x - camera.x, map.y  - camera.y)
	
	
	love.graphics.setBackgroundColor(0, 0, 0)
	
	love.graphics.setColor(180,180,180)
	love.graphics.rectangle("fill", map.x - map.width/2, map.y - map.height/2, map.width, map.height)
	
	--love.graphics.draw(backgroundimage, map.x - map.width/2, map.y - map.height/2)
	
	--love.graphics.draw(tile.image, 0,0)
	
	drawTileBackground(tile)
	drawFlowers()
	
	playerdrawn = false
	love.graphics.setLineWidth(3)
	for i,v in pairs(enemies) do
		if collision.rectangles(v.x-v.width/2,v.y-v.height/2,v.width,v.height,   camera.x-camera.width/2, camera.y-camera.height/2, camera.width, camera.height) then
			
			--[[
			if v.width < player.width then
				love.graphics.setColor(0,200,0)
			else
				love.graphics.setColor(255,0,0)
			end
			]]
			
			--love.graphics.rectangle('fill', v.x-v.width/2, v.y-v.height/2, v.width, v.height)
			if v.width > player.width then
				--love.graphics.draw(enemypic, v.x-v.width/2, v.y-v.height/2, 0, v.width/enemypicwidth, v.width/enemypicwidth)
			else
				--love.graphics.draw(enemysadpic, v.x-v.width/2, v.y-v.height/2, 0, v.width/enemypicwidth, v.width/enemypicwidth)
			end
			
			
			love.graphics.setColor(unpack(v.color))
			love.graphics.draw(player.image, v.x-v.width/2, v.y - v.height/2, 0, v.width/player.imagewidth, v.height/player.imageheight)
			
			if v.width < player.width and not playerdrawn then
				drawPlayer()--love.graphics.draw(player.image, player.x-player.width/2, player.y - player.height/2, 0, player.width/player.imagewidth, player.height/player.imageheight)
			end
		end
	end
	
	if not playerdrawn then
		drawPlayer()
	end
	
	love.graphics.setColor(unpack(player.color))
	if paused then
		love.graphics.setColor(255,255,0)
	end
	
	--Former Player Draw
	--[[if player.image then
		love.graphics.draw(player.image, player.x-player.width/2, player.y - player.height/2, 0, player.width/player.imagewidth, player.height/player.imageheight)
	else
		love.graphics.rectangle('fill', player.x-player.width/2, player.y-player.height/2, player.width, player.height)
	end]]
	
	
	--[[
	love.graphics.setColor(255,0,0,100)
	love.graphics.rectangle('fill', map.x-map.width/2 + camera.width/2, map.y - map.height/2 + camera.height/2,  (map.x+map.width/2 - camera.width/2) - ( map.x-map.width/2 + camera.width/2), (map.y + map.height/2 - camera.height/2) - (map.y - map.height/2 + camera.height/2)) 
	]]
	
	love.graphics.setColor(0,190,0,100)
	--love.graphics.rectangle("fill", camera.x-camera.width/2, camera.y-camera.height/2, camera.width, camera.height)
	
	
	love.graphics.pop()
	
	
	
	
	love.graphics.setColor(187,187,187)
	love.graphics.rectangle("fill",0,0, hud.width, hud.height)
	
	love.graphics.setLineWidth(10)
	love.graphics.setColor(220,220,220)
	love.graphics.rectangle("line",0,-8, hud.width, hud.height)
	
	love.graphics.setFont(defaultFont)
	
	love.graphics.setColor(0,0,0)
	fps = love.timer.getFPS()
	love.graphics.print("FPS: " .. fps, 7,3)
	
	love.graphics.setFont(smallFont)
	love.graphics.print("Biggest: " .. math.floor(player.biggestwidth), 10,20)
	love.graphics.print("Size: " .. math.floor(player.width), 10,40)
	love.graphics.print("Base Width: " .. math.round(player.basewidth,1), 10,60)
	love.graphics.print("Enemies Eaten: " .. player.cubeseaten, 10,80)
	
	love.graphics.setFont(basicFont)
	--love.graphics.setFont(blurryfont)
	local minutes = math.floor(player.timealive/60)
	local seconds = player.timealive - minutes*60
	if seconds < 10 then
		love.graphics.print(minutes .. ":" .. "0" .. math.floor(seconds), 640,10)
	else
		love.graphics.print(minutes .. ":" .. math.floor(seconds), 640,10)
	end
	
	love.graphics.setFont(giantDefaultFont)
	love.graphics.print("Score:", 220,10)
	
	if player.touchingenemy or player.width < player.basewidth then
		love.graphics.setColor(255,10,10)
	else
		love.graphics.setColor(0,200,0)
	end
	love.graphics.setFont(giantFont)
	love.graphics.print(math.floor(player.score), 460,0)
	
	love.graphics.setFont(moneyFont)
	love.graphics.setColor(0,0,0)
	love.graphics.print("High Score: ", 260, 80)
	love.graphics.print(math.round(player.highscore,1), 380, 80)
	
	love.graphics.setFont(defaultFont)
	love.graphics.setColor(255,255,255)
	love.graphics.print(#enemies, 10,230)
	
	if paused then
		if player.alive then
			love.graphics.setColor(240,240,240,150)
		else
			love.graphics.setColor(240,0,0,150)
		end
		love.graphics.rectangle("fill", 0,hud.height,WINDOWWIDTH, WINDOWHEIGHT-hud.height)
		
		
		local x,y = love.mouse.getPosition()

		if x > WINDOWWIDTH/2-156 and x < WINDOWWIDTH/2 + 144 and y > WINDOWHEIGHT/2 - 52 and y < WINDOWHEIGHT/2 + 48 then
			love.graphics.setColor(240,240,240,200)
		else
			love.graphics.setColor(240,240,240,150)
		end
		
		love.graphics.rectangle("fill", WINDOWWIDTH/2-156, WINDOWHEIGHT/2 - 52, 300, 100)
		
		love.graphics.setFont(giantFont)
		
		if player.alive then
			love.graphics.setColor(120,120,120)
			love.graphics.print("Paused", WINDOWWIDTH/2-140, WINDOWHEIGHT/2 - 60)
		else
			love.graphics.setColor(200,0,0)
			love.graphics.print("Dead", WINDOWWIDTH/2-140+43, WINDOWHEIGHT/2 - 60)
		end
	end
	
	if camerainfo then
		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle('fill', 0,hud.height, 230, 250 - hud.height)
	
		love.graphics.setFont(defaultFont)
		love.graphics.setColor(255,255,255)
		
		love.graphics.print("X: " .. math.round(camera.x, 0.01), 10,130)
		love.graphics.print("Y: " .. math.round(camera.y, 0.01), 80,130)
		
		love.graphics.print("Width: " .. math.round(camera.width, 0.1), 10,150)
		love.graphics.print("Height: " .. math.round(camera.height, 0.1), 120,150)
		love.graphics.print("Xscale: " .. math.round(camera.xscale, 0.01), 10,170)
		love.graphics.print("Target: " .. math.round(camera.targetzoom, 0.01), 120,170)
		
		love.graphics.print("Zoom Step: " .. camera.zoomstep, 10, 190)
		love.graphics.print("Zooming: " .. tostring(camera.zooming), 10, 210)
		
		love.graphics.print("Width: " .. math.round(camera.originalwidth/camera.xscale, 0.1), 110,230)
		--love.graphics.print(tostring(camera.onedge), 10,180)
	end
	
	if mapinfo then
		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle('fill', 590,hud.height, 230, 250 - hud.height)
	
		love.graphics.setFont(defaultFont)
		love.graphics.setColor(255,255,255)
	
		love.graphics.print("X: " .. math.round(map.x, 0.01), 600,130)
		love.graphics.print("Y: " .. math.round(map.y, 0.01), 670,130)
	
		love.graphics.print("Width: " .. math.round(map.width, 0.1), 600,150)
		love.graphics.print("Height: " .. math.round(map.height, 0.1), 600,170)
		
		love.graphics.print(player.cells, 600, 190)
	
	end
	
	if playerinfo then
		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle('fill', 250,hud.height, 200, 240 - hud.height)
	
		love.graphics.setFont(defaultFont)
		love.graphics.setColor(255,255,255)
	
		love.graphics.print("X: " .. math.round(player.x, 0.01), 260,130)
		love.graphics.print("Y: " .. math.round(player.y, 0.01), 330,130)
		
		love.graphics.print(tostring(player.horizontal) .. ' ' .. tostring(player.vertical), 260,150)

		if touch.x and touch.y then
			local x,y = getWorldPoint(touch.x,touch.y)
			love.graphics.print(math.round(x, 0.01) .. ' ' .. math.round(y, 0.01), 260,170)
		end

		local screenx,screeny = getScreenPoint(player.x,player.y)

		love.graphics.print("X: " .. math.round(screenx, 0.01), 260,190)
		love.graphics.print("Y: " .. math.round(screeny, 0.01), 330,190)
	
		love.graphics.print("cW: " .. math.round(WINDOWWIDTH, 0.01), 260,220)
		love.graphics.print("cH: " .. math.round(WINDOWHEIGHT, 0.01), 330,220)
	
	end

	if not hideMoveCircles then
		if touch.id ~= 0 then
			if touch.x < WINDOWWIDTH/2 then
				highlightMoveCircle(moveCircleLeft)
			else
				highlightMoveCircle(moveCircleRight)
			end
		end
		drawMoveCircle(moveCircleRight)
		drawMoveCircle(moveCircleLeft)
	end

	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',WINDOWWIDTH-150,hud.height,150,200)

	love.graphics.setColor(255,255,255)
	love.graphics.print(#touches,WINDOWWIDTH-150,hud.height+20)
	for i,v in pairs(touches) do
		love.graphics.print(math.round(v.x,0.1) .. ' ' .. math.round(v.y,0.1),WINDOWWIDTH-150,hud.height+20*i)
	end

	-- FPS cap
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(1*(next_time - cur_time))


	
end

function highlightMoveCircle(circle)
	love.graphics.setColor(255,250,0,100)
	love.graphics.circle('fill',circle.x,circle.y,circle.radius)
end

function drawMoveCircle(circle)
	love.graphics.setColor(0,220,0,150)
	love.graphics.circle('fill',circle.x,circle.y,circle.radius)

	love.graphics.setColor(0,0,0,200)
	love.graphics.circle('fill',circle.x,circle.y,circle.radius/10)


	love.graphics.setLineWidth(8)
	love.graphics.setColor(180,50,30)
	for i=0,7 do
		local angle = i*math.pi/4
		love.graphics.drawArrow(circle.x+math.cos(angle)*circle.radius/7, circle.y+math.sin(angle)*circle.radius/8,angle,circle.radius*0.75)
	end
end


function drawPlayer()
	love.graphics.setColor(unpack(player.color))
	if paused then
		love.graphics.setColor(255,255,0)
	end
	if player.cells == 1 then
		love.graphics.draw(player.image, player.x-player.width/2, player.y - player.height/2, 0, player.width/player.imagewidth, player.height/player.imageheight)
	else
		local cellwidth = player.width/player.cells
		local left = player.x-player.width/2
		local top = player.y-player.width/2
		local cellheight = player.height/player.cells
		for i = 1, player.cells do
			love.graphics.draw(player.image, left, top, 0, cellwidth/player.imagewidth, player.height/player.imageheight)
			left = left + cellwidth
			if left >= player.x+player.width/2 then
				left = player.x-player.width/2
				top = top + cellheight
			end
		end
	end
end


function game.reload()
	player = {x = 400, y = 400,minsize = 10,maxsize = 80, width = 20, speed = 500, touchingenemy = false, color={255,255,255}, cubeseaten = 0, score = 1,highscore = player.highscore, basewidth = 0, biggestwidth = 10, alive = true, timealive = 0, invincible = false, won = false, image = love.graphics.newImage("Assets/Images/cell.png"), cells = 1, cellwidth = 20}
	cellsize = 25
	player.imagewidth = player.image:getWidth()
	player.imageheight = player.image:getHeight()
	player.heightproportion = 1 --player.imageheight/player.imagewidth
	player.height = player.width * player.heightproportion
	
	enemies = {}--{x = 100, y = 100, width = 32, height = 32, speed = 5}
	
	level = {number = 3, win = 70}
	
	clearscreen = true
	paused = true
	
	
	ENEMYSPAWNRATE = 5^-1
	enemyspawnrate = 0
	maxenemies = 30
	

	enemypic = love.graphics.newImage("Assets/Images/eyebrows.png")
	enemysadpic = love.graphics.newImage("Assets/Images/sad.png")
	enemypicwidth = enemypic:getWidth()

	
	flowerpics = {love.graphics.newImage('Assets/Images/Flowers/flower-pink.png'), love.graphics.newImage('Assets/Images/Flowers/flower-black.png'),love.graphics.newImage('Assets/Images/Flowers/flower-green.png'),love.graphics.newImage('Assets/Images/Flowers/flower-purple.png')}
	
	originalflowersize = flowerpics[1]:getWidth()
	flowersize =  originalflowersize * 3
	
	hud = {width = WINDOWWIDTH, height = 120}
	
	camera.initialize(WINDOWWIDTH/2, (WINDOWHEIGHT-hud.height)/2 + hud.height, WINDOWWIDTH, (WINDOWHEIGHT -hud.height))

	scale = 1
	camerainfo = true
	mapinfo = true
	playerinfo = true
	
	map = {width = WINDOWWIDTH*8, height = (WINDOWHEIGHT -hud.height) * 8, x = WINDOWWIDTH/2, y = (WINDOWHEIGHT-hud.height)/2 + hud.height}
	
	player.x = map.x + map.width/2 - player.speed*3
	player.y = player.speed*3

	flowernumber = 200
	flowers = {}
	math.randomseed(123)
	for i = 1, flowernumber do
		local x = math.random(map.x - map.width/2, map.x + map.width/2 - flowersize/2)
		local y = math.random(map.y - map.height/2, map.y + map.height/2 - flowersize/2)
		local pic = math.random(1, #flowerpics)
		local rot = math.random(0, 2*math.pi)
		
		
		for i,v in pairs(flowers) do
			while (x-v[1])^2 + (y-v[2])^2 < flowersize/5 do
				x = math.random(map.x - map.width/2, map.x + map.width/2 - flowersize/2)
				y = math.random(map.y - map.height/2, map.y + map.height/2 - flowersize/2)
			end
		end
		
		
		table.insert(flowers, {x, y, pic, rot} )
		
		
		
		
	end
	
	math.randomseed(os.time())
	
	
	if (player.x - camera.width/2) > (map.x-map.width/2) and (player.x + camera.width/2) < (map.x + map.width/2) then
		camera.x = player.x
	end
	
	if (player.y - camera.height/2) > (map.y-map.height/2) and (player.y + camera.height/2) < (map.y + map.height/2) then
		camera.y = player.y
	end
		
		
	scale = 1
	
	
	-- FPS cap
	min_dt = 1/60
	next_time = love.timer.getTime()
end


function game.run()

    math.randomseed(os.time())
    math.random() math.random()

    if game.load then game.load(arg) end

    local dt = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        if game.update then game.update(dt) end -- will pass 0 if love.timer is disabled
        if love.graphics then
            if game.draw then game.draw() end
        end

        if love.timer then love.timer.sleep(0.001) end
        if love.graphics then love.graphics.present() end
		if clearscreen then
			love.graphics.clear()
		end
			
    end

end

function love.graphics.drawArrow(x,y, angle, length)
	local endx, endy = x+math.cos(angle)*length, y+math.sin(angle)*length
	love.graphics.line(x,y,endx,endy)

	local a = angle + math.pi/4
	local l = -length/4

	local c,d = endx+math.cos(a)*l, endy+math.sin(a)*l
	love.graphics.line(endx,endy, c,d)

	a = angle - math.pi/4

	local e,f = endx+math.cos(a)*l, endy+math.sin(a)*l
	love.graphics.line(endx,endy, e,f)
end