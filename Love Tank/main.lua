--[[
titlepage = {}
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "q" then
		if SLOWMOTION == 1 then
			SLOWMOTION = 2
		else
			SLOWMOTION = 1
		end
	end
	

end
function love.run()
end

function titlepage.load()
	smallFont = love.graphics.newFont("FreeSansBold.ttf",20*96/140)
	scoreFont = love.graphics.newFont("FreeSansBold.ttf",30*96/140)
	moneyFont = love.graphics.newFont("FreeSansBold.ttf",30*96/140)
	basicFont = love.graphics.newFont("FreeSansBold.ttf",48*96/140)
	giantFont = love.graphics.newFont("FreeSansBold.ttf",110*96/140)
	largeFont = love.graphics.newFont("FreeSansBold.ttf",96)
	
	FPS = 40
	WINDOWWIDTH = 800--800
	WINDOWHEIGHT = 650
	love.graphics.setBackgroundColor(0,0,0,0)
	love.graphics.setMode(WINDOWWIDTH, WINDOWHEIGHT, false, true, 0)
	
	playbutton = {WINDOWWIDTH/2 - 350/2,WINDOWHEIGHT*.7, 350, 80} --left, top, width, height
end


function titlepage.update(dt)
	
end

function titlepage.draw(dt)
	love.graphics.setColor(180,12,231)
	love.graphics.rectangle("fill", unpack(playbutton))
end



local dt = 0

titlepage.load()

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
	titlepage.update(dt)-- will pass 0 if love.timer is disabled
	if love.graphics then
		if true then
			love.graphics.clear()
		end
		titlepage.draw(dt)
	end

	if love.timer then love.timer.sleep(0.001) end
	if love.graphics then love.graphics.present() end

end












]]


function beginContact(a,b,contact)
	boxhit = false
	found = false
	missilehit = false
	playerhit = false
	adata = a:getUserData()
	bdata = b:getUserData()

	if adata == "missile" or bdata == "missile" then
		if adata == "enemy" or bdata == "enemy" then
			for category in pairs(enemies) do
				if not found then
					for i in pairs(enemies[category]) do
						if a == enemies[category][i].fixture or b == enemies[category][i].fixture then
							enemies[category][i].hurt = ENEMYHURTTIME					
							enemies[category][i].health = enemies[category][i].health - MISSILEATTACK
							n = i
							typ = category
							found = true
							break
						end
					end
				end
			end	
			
			
			if  enemies[typ][n].explosiontime == 0 then
				for i in pairs(playermissiles) do
					if a == playermissiles[i].fixture or b == playermissiles[i].fixture then
						playermissiles[i].pierce = playermissiles[i].pierce - 1
						if playermissiles[i].pierce <= 0 then
							playermissiles[i].body:destroy()
							table.remove(playermissiles,i)
						end
						break
					end
				end
				if enemies[typ][n].health <= 0 then
					enemies[typ][n].explosiontime = EXPLOSIONTIME
					enemies[typ][n].body:setLinearVelocity(0,0)
					enemies[typ][n].body:setLinearDamping(500)
					enemies[typ][n].fixture:destroy()
					table.insert(newcoinlist,{})
					w = #newcoinlist
					newcoinlist[w].body = {world, enemies[typ][n].body:getX(),enemies[typ][n].body:getY(), "dynamic"}
				end
			end
		elseif adata=="box" or bdata=="box" then
			contact:setRestitution(1)
			contact:setFriction(0)
		end
	elseif adata == "enemy" or bdata == "enemy" then
		if adata == "player" or bdata == "player" then
			for category in pairs(enemies) do
				for i in pairs(enemies[category]) do
					if a == enemies[category][i].fixture or b == enemies[category][i].fixture then
						n = i
						typ = category
						break
					end
				end
			end
			
			if COOLDOWNTIME <= 0 then
				if enemies[typ][n].explosiontime <= 0 then
					enemies[typ][n].hurt = ENEMYHURTTIME
					COOLDOWNTIME = 2
					PLAYERHEALTH = PLAYERHEALTH - 1
					if PLAYERHEALTH <= 0 then
						dead = true
						PLAYERHEALTH = 0
					end
					if typ == "icy" then
						player.frozentime = player.frozentime + icyfreeze
					end
				end
			end
		end
	elseif adata == "enemy missile" or bdata == "enemy missile" then
		if adata == "player" or bdata == "player" then
			for i in pairs(icymissiles) do
				if a == icymissiles[i].fixture or b == icymissiles[i].fixture then
					icymissiles[i].body:destroy()
					table.remove(icymissiles,i)
					break
				end
			end
			player.frozentime = player.frozentime + icymissilefreeze
		end
	end
end

function preSolve(a,b,contact)
	boxhit = false
	found = false
	missilehit = false
	playerhit = false
	adata = a:getUserData()
	bdata = b:getUserData()
	
	if adata == "missile" or bdata == "missile" then
		if adata=="missile" and bdata=="missile" then
			contact:setEnabled(false)
		else
			contact:setEnabled(false)
		end
		
		if adata == "box" or bdata == "box" then
			if missilebounce then	
				contact:setEnabled(true)
				contact:setRestitution(1)
				contact:setFriction(0)
			end
		end
	elseif adata == "enemy" and bdata == "enemy" then
		contact:setEnabled(false)
	elseif adata == "enemy" or bdata == "enemy" then
		if adata == "player" or bdata == "player" then
			contact:setEnabled(false)
		elseif adata == "box" or bdata =="box" then
			contact:setRestitution(1)
			if not missilehit and not found then
				for i in pairs(box) do
					if not found then
						if a == box[i].fixture or b == box[i].fixture then
							boxhit = true
							for category in pairs(enemies) do
								if not found then
									for d in pairs(enemies[category]) do
										if a == enemies[category][d].fixture or b == enemies[category][d].fixture then
											x,y = enemies[category][d].body:getLinearVelocity()
											if i== 1 and y > 0 then
												contact:setEnabled(false)
											elseif i == 2 and  x < 0 then
												contact:setEnabled(false)
											elseif i == 3 and y < 0 then
												contact:setEnabled(false)
											elseif i == 4 and x  > 0 then
												contact:setEnabled(false)
											end
											found= true
											break
										end
									end	
								end
							end	
						end
					end
				end
			end
		elseif adata == "enemy missile" or bdata == "enemy missile" then
			contact:setEnabled(false)
		end	
	elseif adata == "enemy missile" or bdata == "enemy missile" then
		contact:setEnabled(false)
	elseif adata == "coin" or bdata == "coin" then
		contact:setEnabled(false)
		if adata == "player" or bdata == "player" then
			for i in pairs(coinlist) do
				if a == coinlist[i].fixture or b == coinlist[i].fixture then
					cash = cash + 5
					coinlist[i].fixture:destroy()
					table.remove(coinlist,i)
					break
				end
			end
		end
	end
	
			
	if adata == "box" or bdata == "box" then
		if adata == "player" or bdata == "player" then
			contact:setEnabled(false)
		end
	end
	
	
	
end

function endContact(a,b,contact)
	adata = a:getUserData()
	bdata = b:getUserData()
	if adata == "enemy missile" or bdata == "enemy missile" then
		if adata == "box" or bdata == "box" then
			for i in pairs(icymissiles) do
				if icymissiles[i].fixture == a or icymissiles[i].fixture == b then
					icymissiles[i].body:destroy()
					table.remove(icymissiles,i)
					break
				end
			end
		end
	end
end
function spawn_baby()
	
	table.insert(enemies.baby, {})
	x = math.random(1,4)
	if x == 2 or x == 4 then
		yspot = math.random(-70, WINDOWHEIGHT+70)
		if x== 2 then
			xspot = WINDOWWIDTH+ 50
		else 
			xspot = -70
		end
	else 
		xspot = math.random(-70, WINDOWWIDTH + 70)
		if x ==1 then
			yspot = -70
		else
			yspot = WINDOWHEIGHT + 70
		end
	end
	x,y = player.body:getPosition()
	slope = (y-yspot)/(x-xspot)
	xspeed = ( (BABYSPEED^2)/(1+slope^2)  )^.5
	if x-xspot <0 then
		xspeed = -math.abs(xspeed)
	end
	yspeed = xspeed*slope
	
	n = #enemies.baby
	enemies.baby[n].body= love.physics.newBody(world, 0,0,"dynamic")	
	enemies.baby[n].shape = love.physics.newPolygonShape(unpack(babypoints))	
	enemies.baby[n].fixture = love.physics.newFixture(enemies.baby[n].body, enemies.baby[n].shape)
	enemies.baby[n].body:setPosition(xspot, yspot)
	enemies.baby[n].body:setLinearVelocity(xspeed, yspeed)
	enemies.baby[n].body:setLinearDamping(.1)
	enemies.baby[n].body:setFixedRotation(true)
	enemies.baby[n].body:setBullet(true)
	enemies.baby[n].hurt = -ENEMYHURTTIME
	enemies.baby[n].fixture:setUserData("enemy")
	enemies.baby[n].fixture:setRestitution(1)
	enemies.baby[n].health = BABYHEALTH
	enemies.baby[n].explosiontime = 0
end
	
function move_baby(dt)
	playerx,playery = player.body:getPosition()
	move = 0.001/dt
	for i in pairs(enemies.baby) do
		xspot,yspot = enemies.baby[i].body:getPosition()
		xspeed,yspeed = enemies.baby[i].body:getLinearVelocity()
		
		if xspot > playerx then
			xspeed = xspeed - move
		else
			xspeed = xspeed + move
		end
		if yspot > playery then
			yspeed = yspeed - move
		else
			yspeed = yspeed + move
		end
		enemies.baby[i].body:setLinearVelocity(xspeed,yspeed)
		
		
	end

end

	
function spawn_icy()
	
	table.insert(enemies.icy, {})
	x = math.random(1,4)
	if x == 2 or x == 4 then
		yspot = math.random(-70, WINDOWHEIGHT+70)
		if x== 2 then
			xspot = WINDOWWIDTH+ 50
		else 
			xspot = -70
		end
	else 
		xspot = math.random(-70, WINDOWWIDTH + 70)
		if x ==1 then
			yspot = -70
		else
			yspot = WINDOWHEIGHT + 70
		end
	end
	x,y = player.body:getPosition()
	slope = (y-yspot)/(x-xspot)
	xspeed = ( (ICYSPEED^2)/(1+slope^2)  )^.5
	if x-xspot <0 then
		xspeed = -math.abs(xspeed)
	end
	yspeed = xspeed*slope
	
	n = #enemies.icy
	enemies.icy[n].body= love.physics.newBody(world, 0,0,"dynamic")	
	enemies.icy[n].shape = love.physics.newPolygonShape(unpack(icypoints))	
	enemies.icy[n].fixture = love.physics.newFixture(enemies.icy[n].body, enemies.icy[n].shape)
	enemies.icy[n].body:setPosition(xspot, yspot)
	enemies.icy[n].body:setLinearVelocity(xspeed, yspeed)
	enemies.icy[n].body:setLinearDamping(0)
	enemies.icy[n].body:setFixedRotation(true)
	enemies.icy[n].body:setBullet(true)
	enemies.icy[n].hurt = -ENEMYHURTTIME
	enemies.icy[n].fixture:setUserData("enemy")
	enemies.icy[n].fixture:setRestitution(1)
	enemies.icy[n].health = ICYHEALTH
	enemies.icy[n].explosiontime = 0
	enemies.icy[n].missileslowdown = -math.random()*2
	enemies.icy[n].portal = false
	enemies.icy[n].portalplace = {}
end


function move_icy()
	for i in pairs(enemies.icy) do
		xpos,ypos = enemies.icy[i].body:getPosition()
		if xpos < WINDOWWIDTH-portalplace/2 and xpos > portalplace/2 and ypos > portalplace/2 and ypos < WINDOWHEIGHT-portalplace/2 then
			xspeed, yspeed = enemies.icy[i].body:getLinearVelocity()
			if not enemies.icy[i].direction then
				if xpos < portalplace then
					if yspeed > 0 then
						enemies.icy[i].direction = "down"
					else
						enemies.icy[i].direction = "up"
					end
				elseif xpos > WINDOWWIDTH - portalplace then
					if yspeed > 0 then
						enemies.icy[i].direction = "down"
					else
						enemies.icy[i].direction = "up"
					end
				elseif ypos < portalplace then
					if xspeed > 0 then
						enemies.icy[i].direction = "right"
					else
						enemies.icy[i].direction = "left"
						enemies.icy[i].portalplace[1] = xpos - 300
					end
				elseif ypos > WINDOWHEIGHT - portalplace then
					if xspeed > 0 then
						enemies.icy[i].direction = "right"
					else
						enemies.icy[i].direction = "left"
						enemies.icy[i].portalplace[1] = xpos - 300
					end
				end
			end
			if enemies.icy[i].portal == false then
				if enemies.icy[i].direction == "left" then
					enemies.icy[i].body:setLinearVelocity(-ICYSPEED, 0)
					if xpos < portalplace then
						if ypos < WINDOWWIDTH/2 then
							enemies.icy[i].body:setPosition(WINDOWWIDTH-portalplace, WINDOWHEIGHT - portalplace)
							a = math.random(0,1)
							if a == 1 then
								enemies.icy[i].direction = "left"
								enemies.icy[i].portalplace[1] = xpos - 300
							else
								enemies.icy[i].direction = "up"
							end
						else
							enemies.icy[i].body:setPosition(WINDOWWIDTH - portalplace, portalplace)
							a = math.random(0,1)
							if a == 1 then
								enemies.icy[i].direction = "right"
							else
								enemies.icy[i].direction = "down"
							end					
						end
					end
				
				elseif enemies.icy[i].direction == "right" then
					enemies.icy[i].body:setLinearVelocity(ICYSPEED, 0)
					if xpos > WINDOWWIDTH - portalplace then
						if ypos < WINDOWWIDTH/2 then
							enemies.icy[i].body:setPosition(portalplace, WINDOWHEIGHT - portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "right"
							else
								enemies.icy[i].direction = "up"
							end
						else
							enemies.icy[i].body:setPosition(portalplace, portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "right"
							else
								enemies.icy[i].direction = "down"
							end					
						end
					end
				elseif enemies.icy[i].direction == "up" then
					enemies.icy[i].body:setLinearVelocity(0,-ICYSPEED)
					if ypos < portalplace then
						if xpos < WINDOWWIDTH/2 then
							enemies.icy[i].body:setPosition(WINDOWWIDTH-portalplace, WINDOWHEIGHT - portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "left"
							else
								enemies.icy[i].direction = "up"
							end
						else
							enemies.icy[i].body:setPosition(portalplace, WINDOWHEIGHT - portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "right"
							else
								enemies.icy[i].direction = "up"
							end					
						end
					end
				elseif enemies.icy[i].direction == "down" then
					enemies.icy[i].body:setLinearVelocity(0,ICYSPEED)
					if ypos > WINDOWHEIGHT - portalplace then
						if xpos < WINDOWWIDTH/2 then
							enemies.icy[i].body:setPosition(WINDOWWIDTH-portalplace, portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "left"
								enemies.icy[i].portalplace[1] = xpos - 300
							else
								enemies.icy[i].direction = "down"
							end
						else
							enemies.icy[i].body:setPosition(portalplace, portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "right"
							else
								enemies.icy[i].direction = "down"
							end					
						end
					end
				end
			elseif enemies.icy[i].portal <= 0 or direction == "left" and xpos - enemies.icy[i].portalplace[1] <= 0 then	
				x,y = enemies.icy[i].body:getPosition()
				good = false
				while not good do
					section = math.random(1,4)
					if section == 1 then
						if y ~= portalplace then
							place = math.random(portalplace+50,WINDOWWIDTH-portalplace-50)
							enemies.icy[i].body:setPosition(place,portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "right"
							else
								enemies.icy[i].direction = "left"
								enemies.icy[i].portalplace[1] = xpos - 300
							end	
							good = true
						end
					elseif section == 3 then
						if y ~= WINDOWHEIGHT - portalplace then
							place = math.random(portalplace+50,WINDOWWIDTH-portalplace-50)
							enemies.icy[i].body:setPosition(place, WINDOWHEIGHT - portalplace)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "right"
							else
								enemies.icy[i].direction = "left"
								enemies.icy[i].portalplace[1] = xpos - 300
							end	
							good = true
						end
					elseif section == 2 then
						if x ~= WINDOWWIDTH - portalplace then
							place = math.random(portalplace+50,WINDOWHEIGHT-portalplace-50)
							enemies.icy[i].body:setPosition(WINDOWWIDTH - portalplace, place)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "up"
							else
								enemies.icy[i].direction = "down"
							end
							good = true
						end
					elseif section == 4 then
						if x ~= portalplace then
							place = math.random(portalplace+50,WINDOWHEIGHT-portalplace-50)
							enemies.icy[i].body:setPosition(portalplace, place)
							a = math.random(0,1)
							if a ==1 then
								enemies.icy[i].direction = "up"
							else
								enemies.icy[i].direction = "down"
							end	
							good = true
						end
					end
				end
				enemies.icy[i].portal = false		
				
			end
		end
	end
end


function love.load()
	smallFont = love.graphics.newFont("FreeSansBold.ttf",20*96/140)
	scoreFont = love.graphics.newFont("FreeSansBold.ttf",30*96/140)
	moneyFont = love.graphics.newFont("FreeSansBold.ttf",30*96/140)
	basicFont = love.graphics.newFont("FreeSansBold.ttf",48*96/140)
	giantFont = love.graphics.newFont("FreeSansBold.ttf",110*96/140)
	largeFont = love.graphics.newFont("FreeSansBold.ttf",96)
	
	FPS = 60
	metersize = 64 --pixels
	WINDOWWIDTH = 800--800
	WINDOWHEIGHT = 500
	love.graphics.setBackgroundColor(0,0,0,0) --set the background color to a nice blue
	HUDHEIGHT = 150
	love.window.setMode(WINDOWWIDTH, WINDOWHEIGHT+HUDHEIGHT)

    love.physics.setMeter(metersize)
    world = love.physics.newWorld(0, 0*metersize, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	backgroundimage = love.graphics.newImage("starry background.png")
	spaceshipimage = love.graphics.newImage("spaceship.png")
	orangeexplosionimage = love.graphics.newImage("explosion.png")--302 x 281
	blueexplosionimage = love.graphics.newImage("blue explosion.png")
	portalimage = love.graphics.newImage("portal.png")--147 x 148
	icymissileimage = love.graphics.newImage("icy comet.png")--105 x 398
	falconimage = love.graphics.newImage("millenium falcon.png")--343 x 471
	coinimage = love.graphics.newImage("coin.png")--26 x 18
	
	coinlist = {}
	
	portalimagescale = .6
	portaloffset = 30
	portalimagewidth,portalimageheight = 147*portalimagescale + portaloffset,148*portalimagescale + portaloffset
	
	-- 171,299
	playerlaunchers = {}
	table.insert(playerlaunchers, {})
	
	playerradius = 15
	launcherwidth = playerradius/1.5
	launcherlength = playerradius*1.5
	
	playerlaunchers[1].body = love.physics.newBody(world, 0, 0, "dynamic")
	playerlaunchers[1].body:setMass(0)
	playerlaunchers[1].shape = love.physics.newPolygonShape(-.5*launcherwidth, launcherlength+playerradius-1,.5*launcherwidth,launcherlength+playerradius-1,   .5*launcherwidth,playerradius-1, -.5*launcherwidth,playerradius-1)
	playerlauncherpoints = {playerlaunchers[1].shape:getPoints()}
	
	playerlaunchers[1].fixture = love.physics.newFixture(playerlaunchers[1].body, playerlaunchers[1].shape, .6)
	playerlaunchers[1].fixture:setRestitution(.9)
	playerlaunchers[1].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
	playerlaunchers[1].body:setBullet(true)
	playerlaunchers[1].body:setLinearDamping(.5)
	playerlaunchers[1].angle = 0
	
	if false then
		table.insert(playerlaunchers, {})
		playerlaunchers[2].body = love.physics.newBody(world, 0, 0, "dynamic")
		playerlaunchers[2].body:setMass(0)
		playerlaunchers[2].shape = love.physics.newPolygonShape(-.5*launcherwidth, -launcherlength-playerradius, .5*launcherwidth,-launcherlength-playerradius,   .5*launcherwidth,-playerradius, -.5*launcherwidth,-playerradius)
		playerlauncherpoints = {playerlaunchers[2].shape:getPoints()}
		playerlaunchers[2].fixture = love.physics.newFixture(playerlaunchers[2].body, playerlaunchers[2].shape, .6)
		playerlaunchers[2].fixture:setRestitution(.9)
		playerlaunchers[2].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		playerlaunchers[2].body:setBullet(true)
		playerlaunchers[2].body:setLinearDamping(.5)
		playerlaunchers[2].angle = 0
		
		
		table.insert(playerlaunchers, {})
		playerlaunchers[3].body = love.physics.newBody(world, 0, 0, "dynamic")
		playerlaunchers[3].body:setMass(0)
		playerlaunchers[3].shape = love.physics.newPolygonShape(-.5*launcherwidth, launcherlength+playerradius-1, .5*launcherwidth,launcherlength+playerradius-1,   .5*launcherwidth,playerradius-1, -.5*launcherwidth,playerradius-1)
		playerlauncherpoints = {playerlaunchers[1].shape:getPoints()}
		
		playerlaunchers[3].fixture = love.physics.newFixture(playerlaunchers[3].body, playerlaunchers[3].shape, .6)
		playerlaunchers[3].fixture:setRestitution(.9)
		playerlaunchers[3].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		playerlaunchers[3].body:setBullet(true)
		playerlaunchers[3].body:setLinearDamping(.5)
		playerlaunchers[3].body:setAngle(math.rad(90))
		playerlaunchers[3].angle = 90
		
		table.insert(playerlaunchers, {})
		playerlaunchers[4].body = love.physics.newBody(world, 0, 0, "dynamic")
		playerlaunchers[4].body:setMass(0)
		playerlaunchers[4].shape = love.physics.newPolygonShape(-.5*launcherwidth, launcherlength+playerradius-1, .5*launcherwidth,launcherlength+playerradius-1,   .5*launcherwidth,playerradius-1, -.5*launcherwidth,playerradius-1)
		playerlauncherpoints = {playerlaunchers[1].shape:getPoints()}
		
		playerlaunchers[4].fixture = love.physics.newFixture(playerlaunchers[4].body, playerlaunchers[4].shape, .6)
		playerlaunchers[4].fixture:setRestitution(.9)
		playerlaunchers[4].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		playerlaunchers[4].body:setBullet(true)
		playerlaunchers[4].body:setLinearDamping(.5)
		playerlaunchers[4].body:setAngle(math.rad(270))
		playerlaunchers[4].angle = 270
		
		table.insert(playerlaunchers, {})
		playerlaunchers[5].body = love.physics.newBody(world, 0, 0, "dynamic")
		playerlaunchers[5].body:setMass(0)
		playerlaunchers[5].shape = love.physics.newPolygonShape(-.5*launcherwidth, launcherlength+playerradius-1, .5*launcherwidth,launcherlength+playerradius-1,   .5*launcherwidth,playerradius-1, -.5*launcherwidth,playerradius-1)
		
		playerlaunchers[5].fixture = love.physics.newFixture(playerlaunchers[5].body, playerlaunchers[5].shape, .6)
		playerlaunchers[5].fixture:setRestitution(.9)
		playerlaunchers[5].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		playerlaunchers[5].body:setBullet(true)
		playerlaunchers[5].body:setLinearDamping(.5)
		playerlaunchers[5].body:setAngle(math.rad(45))
		playerlaunchers[5].angle = 45
		
		table.insert(playerlaunchers, {})
		playerlaunchers[6].body = love.physics.newBody(world, 0, 0, "dynamic")
		playerlaunchers[6].body:setMass(0)
		playerlaunchers[6].shape = love.physics.newPolygonShape(-.5*launcherwidth, launcherlength+playerradius-1, .5*launcherwidth,launcherlength+playerradius-1,   .5*launcherwidth,playerradius-1, -.5*launcherwidth,playerradius-1)
		
		playerlaunchers[6].fixture = love.physics.newFixture(playerlaunchers[6].body, playerlaunchers[6].shape, .6)
		playerlaunchers[6].fixture:setRestitution(.9)
		playerlaunchers[6].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		playerlaunchers[6].body:setBullet(true)
		playerlaunchers[6].body:setLinearDamping(.5)
		playerlaunchers[6].body:setAngle(math.rad(135))
		playerlaunchers[6].angle = 135
		
		table.insert(playerlaunchers, {})
		playerlaunchers[7].body = love.physics.newBody(world, 0, 0, "dynamic")
		playerlaunchers[7].body:setMass(0)
		playerlaunchers[7].shape = love.physics.newPolygonShape(-.5*launcherwidth, launcherlength+playerradius-1, .5*launcherwidth,launcherlength+playerradius-1,   .5*launcherwidth,playerradius-1, -.5*launcherwidth,playerradius-1)
		playerlauncherpoints = {playerlaunchers[1].shape:getPoints()}
		
		playerlaunchers[7].fixture = love.physics.newFixture(playerlaunchers[7].body, playerlaunchers[7].shape, .6)
		playerlaunchers[7].fixture:setRestitution(.9)
		playerlaunchers[7].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		playerlaunchers[7].body:setBullet(true)
		playerlaunchers[7].body:setLinearDamping(.5)
		playerlaunchers[7].body:setAngle(math.rad(225))
		playerlaunchers[7].angle = 225
		
		table.insert(playerlaunchers, {})
		playerlaunchers[8].body = love.physics.newBody(world, 0, 0, "dynamic")
		playerlaunchers[8].body:setMass(0)
		playerlaunchers[8].shape = love.physics.newPolygonShape(-.5*launcherwidth, launcherlength+playerradius-1, .5*launcherwidth,launcherlength+playerradius-1,   .5*launcherwidth,playerradius-1, -.5*launcherwidth,playerradius-1)
		playerlauncherpoints = {playerlaunchers[1].shape:getPoints()}
		
		playerlaunchers[8].fixture = love.physics.newFixture(playerlaunchers[8].body, playerlaunchers[8].shape, .6)
		playerlaunchers[8].fixture:setRestitution(.9)
		playerlaunchers[8].body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		playerlaunchers[8].body:setBullet(true)
		playerlaunchers[8].body:setLinearDamping(.5)
		playerlaunchers[8].body:setAngle(math.rad(315))
		playerlaunchers[8].angle = 315
	end
	
	playercirclepoints = {}
	x = -playerradius
	while x <= playerradius do
		y = (  (playerradius^2) - (x^2)     )^.5
		table.insert(playercirclepoints, x)
		table.insert(playercirclepoints, y)
		x = x + 5
	end
	x = playerradius - 5
	while x > -playerradius do
		y = -(  (playerradius^2) - (x^2)     )^.5
		table.insert(playercirclepoints, x)
		table.insert(playercirclepoints, y)
		x = x - 5
	end
	
	player = {}
	player.body = love.physics.newBody(world, 0,0, "dynamic")
	playerdamping = 2
	player.body:setLinearDamping(playerdamping)
	--player.shape = love.physics.newCircleShape(playerradius)
	player.shape = love.physics.newChainShape(true, unpack(playercirclepoints))
	player.fixture = love.physics.newFixture(player.body, player.shape,1)
	player.body:setBullet(true)
	
	player.body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
	
	player.fixture:setUserData("player")
	for i in pairs(playerlaunchers) do
		playerlaunchers[i].fixture:setUserData("player")
	end
	
		box = {}
		
		table.insert(box, {})
		table.insert(box, {})
		table.insert(box, {})
		table.insert(box, {})
		linewidth = 3
		box[1].body = love.physics.newBody(world, 0,0, "static")
		box[2].body = love.physics.newBody(world, 0,0, "static")
		box[3].body = love.physics.newBody(world, 0,0, "static")
		box[4].body = love.physics.newBody(world, 0,0, "static")
		
		box[1].shape = love.physics.newPolygonShape(-20,-20, WINDOWWIDTH-0,-20,  WINDOWWIDTH-0, 0+linewidth,   0, 0+linewidth)
		box[2].shape = love.physics.newPolygonShape(WINDOWWIDTH-0-linewidth,-20, WINDOWWIDTH+20,-20,  WINDOWWIDTH+20, WINDOWHEIGHT+20,   WINDOWWIDTH-0-linewidth, WINDOWHEIGHT)
		box[3].shape = love.physics.newPolygonShape(0,WINDOWHEIGHT-linewidth, WINDOWWIDTH,WINDOWHEIGHT-linewidth,  WINDOWWIDTH+20,WINDOWHEIGHT+20,   -20, WINDOWHEIGHT+20)
		box[4].shape = love.physics.newPolygonShape(-20,-20, linewidth + 0,0,  linewidth + 0, WINDOWHEIGHT-0,   -20, WINDOWHEIGHT+20)
		
		box[1].fixture = love.physics.newFixture(box[1].body, box[1].shape,.6)
		box[2].fixture = love.physics.newFixture(box[2].body, box[2].shape,.6)
		box[3].fixture = love.physics.newFixture(box[3].body, box[3].shape,.6)
		box[4].fixture = love.physics.newFixture(box[4].body, box[4].shape,.6)
		
		box[1].fixture:setRestitution(1)
		box[2].fixture:setRestitution(1)
		box[3].fixture:setRestitution(1)
		box[4].fixture:setRestitution(1)
		box[1].fixture:setUserData("box")
		box[2].fixture:setUserData("box")
		box[3].fixture:setUserData("box")
		box[4].fixture:setUserData("box")
				
	
	MAXPLAYERHEALTH = 12
	PLAYERHEALTH = MAXPLAYERHEALTH
	HEALTHBARWIDTH = 20
	COOLDOWNTIME = 0
	dead = false	
		
	last4list = {}
	firstloop = false
	Rectspeed = {}
	playermissiles = {}
	waittime = 0
	PLAYERFORCE = 1000
	MAXPLAYERSPEED = 550--250
	
	missilelength = 10
	missilewidth = 4
	PLAYERMISSILESPEED = 400--400--200
	playermissiles = {}
	playermissileslowdown = 5
	PLAYERMISSILESLOWDOWN = 0.2 --0.2second
	missileradius = 10--launcherwidth/1.5
	playerrotation = 0
	MISSILEATTACK = 1
	MISSILEPIERCE = 2
	MISSILEDAMPING = 0
	missilebounce = false
	
	cash = 0
	MAGNETRADIUS = 200
	MAGNETFORCE = 20
	newcoinlist = {}
	
	enemies = {}
	
	enemies.baby = {}
	babyspawnrate = 2
	BABYSPAWNRATE = 0
	babypoints = {-5, -6,    5, -6,   4.67, -4.0,   10.0, 6,    -10, 6,    -5, -4.0}
	BABYSPEED = 60
	MAXBABYSPEED = 100
	babymoveslowdown = 0
	BABYMOVESLOWDOWN = 0--.5
	BABYHEALTH = 1
	
	enemies.icy = {}
	icypoints = {-18, 0,   0, -18,   18, 0,  13,18,  -13,18}
	ICYSPAWNRATE = 0.5
	icyspawnrate = 5
	portalplace = 100
	ICYSPEED = 100
	ICYHEALTH = 5
	icymissiles = {}
	icymissilewidth = 6
	icymissilelength = 23
	icymissileimagescale = icymissilewidth/80
	icymissilepoints = {0,-icymissilewidth/2,  icymissilelength,-icymissilewidth/2,  icymissilelength,icymissilewidth/2,  0,icymissilewidth/2} 
	ICYMISSILESPEED = 200
	ICYMISSILESLOWDOWN = 1.3 -- seconds
	icymissileslowdown = 0
	player.frozentime = 0
	icymissilefreeze = 4
	icyfreeze = 8
	maxfreeze = 15
	
	EXPLOSIONTIME = 1
	EXPLOSIONSCALE = 20/301
	ENEMYHURTTIME = 9
	flash = "white" 

	paused = false
	slope = 0
	lastmousepoints = {}
	x,y = love.mouse.getPosition()
	table.insert(lastmousepoints, {x,y})
	table.insert(lastmousepoints, {x,y})
	table.insert(lastmousepoints, {x,y})
	table.insert(lastmousepoints, {x,y})
	
	SLOWMOTION = 1
	
	
	min_dt = 1/FPS
    next_time = love.timer.getTime()
   
end


stopenemies = false

function love.keypressed(key)
	if key == "space" then
		firing = not firing
	elseif key == "r" then
		player.body:setPosition(WINDOWWIDTH/2, WINDOWHEIGHT/2)
		player.body:setAngle(0)
		player.body:setLinearVelocity(0,0)
		dead = false
		PLAYERHEALTH = MAXPLAYERHEALTH
		COOLDOWNTIME = 0
	elseif key == "escape" then
		love.event.quit()
	elseif key == "q" then
		if SLOWMOTION == 1 then
			SLOWMOTION = 2
		else
			SLOWMOTION = 1
		end
	elseif key == "l" then
		stopenemies = not stopenemies
	elseif key == "-" then
		if MAXPLAYERHEALTH <= 0 then
			MAXPLAYERHEALTH = 10
		end
		MAXPLAYERHEALTH = MAXPLAYERHEALTH - 1
		PLAYERHEALTH = MAXPLAYERHEALTH
	elseif key == "p" then
		paused = not paused
	elseif key == "t" then 
		for i in pairs(enemies.icy) do
			enemies.icy[i].portal = 255
		end
	elseif key == "m" then
		missilebounce = not missilebounce
	end
	

end

function love.update(dt)
	next_time = next_time + min_dt
	
	if not dead and not paused then
		world:update(dt/SLOWMOTION) --this puts the world into motion
		if COOLDOWNTIME > 0 then
			COOLDOWNTIME = COOLDOWNTIME - dt
		end
		x,y = player.body:getPosition()
		xspeed, yspeed = player.body:getLinearVelocity()
		speed = (xspeed*xspeed + yspeed*yspeed)^.5
		if speed > MAXPLAYERSPEED then
			slope = (yspeed)/(xspeed)
			oldxspeed = xspeed
			xspeed = ( (MAXPLAYERSPEED^2)/(1+slope^2)  )^.5
			if oldxspeed <0 then
				xspeed = -math.abs(xspeed)
			end
			yspeed = xspeed*slope
		end 
		
		player.body:setLinearVelocity(xspeed, yspeed)
		if x - playerradius < 0 then
			player.body:setX(playerradius)
			player.body:setLinearVelocity(-xspeed, yspeed)
		elseif x + playerradius > WINDOWWIDTH then
			player.body:setX(WINDOWWIDTH-playerradius)
			player.body:setLinearVelocity(-xspeed, yspeed)
		end
		
		xspeed, yspeed = player.body:getLinearVelocity()
		
		if y - playerradius < 0 then
			player.body:setY(playerradius)
			player.body:setLinearVelocity(xspeed, -yspeed)
		elseif y + playerradius > WINDOWHEIGHT then
			player.body:setY(WINDOWHEIGHT-playerradius)
			player.body:setLinearVelocity(xspeed, -yspeed)
		end
		
		
			
		x,y = player.body:getPosition()
		for i in pairs(playerlaunchers) do
			playerlaunchers[i].body:setPosition(x,y)
		end
		mousex,mousey = love.mouse.getPosition()
		
		if player.frozentime > 0 then
			if player.frozentime > maxfreeze then
				player.frozentime = maxfreeze
			end
			player.body:setLinearDamping(playerdamping+player.frozentime+2)
		end
		
		if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
			player.body:applyForce(0, PLAYERFORCE)
		elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
			player.body:applyForce(0, -PLAYERFORCE)
		end
		
		if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
			player.body:applyForce(PLAYERFORCE,0)
		elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
			player.body:applyForce(-PLAYERFORCE,0)
		end

		if mousex-x ~= 0 then
			slope = (mousey-y)/(mousex-x)
			b = mousey - mousex*slope
		end
		
		if not love.mouse.isDown(2)  then
			if math.abs(mousex-x) > 0 or math.abs(mousey-y) > 0 then
				if mousex < x then
					playerrotation = math.atan(slope) + math.rad(90)
				elseif mousex > x then
					playerrotation = math.atan(slope) + math.rad(270)
				end
				
				for i in pairs(playerlaunchers) do					
					playerlaunchers[i].body:setAngle(playerrotation + math.rad(playerlaunchers[i].angle))
				end
			end
			
		else
		
			for i in pairs(playerlaunchers) do
				playerlaunchers[i].body:setAngle(playerrotation)
			end
		end

		if playermissileslowdown > PLAYERMISSILESLOWDOWN and love.mouse.isDown(1) then 
			
			for i in pairs(playerlaunchers) do
				x1,y1, x2,y2,x3,y3,x4,y4 = playerlaunchers[i].body:getWorldPoints(playerlaunchers[i].shape:getPoints())
				angle = playerlaunchers[i].body:getAngle()
				yspeed = math.cos(angle) * PLAYERMISSILESPEED
				xspeed = -math.sin(angle) * PLAYERMISSILESPEED

				x,y = player.body:getPosition()
				-- yspeed = (  ((PLAYERMISSILESPEED^2)*(y4-y1)^2)/ (  ((y4-y1)^2) +  ((x4-x1)^2)  )      ) ^.5 
				-- centery = (y1+y2)/2
				-- if centery < y then
				-- 	yspeed = -math.abs(yspeed)
				-- end

				-- xspeed = math.abs(((x4-x1)*yspeed)/(y4-y1))
				-- centerx = (x1+x2)/2
				-- if centerx < x then
				-- 	xspeed = -math.abs(xspeed)
				-- end

				table.insert(playermissiles, {})
				playermissiles[#playermissiles].body = love.physics.newBody(world, x,y, "dynamic", 20)
				playermissiles[#playermissiles].shape = love.physics.newCircleShape(missileradius)
				playermissiles[#playermissiles].fixture = love.physics.newFixture(playermissiles[#playermissiles].body, playermissiles[#playermissiles].shape)
				
				playermissiles[#playermissiles].body:setLinearVelocity(xspeed, yspeed)
				playermissiles[#playermissiles].body:setLinearDamping(MISSILEDAMPING)
				playermissiles[#playermissiles].fixture:setRestitution(1)
				playermissiles[#playermissiles].fixture:setUserData("missile")
				playermissiles[#playermissiles].pierce = MISSILEPIERCE
				
			end
			
			playermissileslowdown = 0
		else
			playermissileslowdown = playermissileslowdown + dt
		end
		
		if love.keyboard.isDown("i") and icyspawnrate > ICYSPAWNRATE then
			icyspawnrate = 0
			spawn_icy()
		else
			icyspawnrate = icyspawnrate + dt		
		end
		
		if babyspawnrate > BABYSPAWNRATE and #enemies.baby < 1000 and love.keyboard.isDown("b") then
			babyspawnrate = 0
			spawn_baby()
		else
			babyspawnrate = babyspawnrate + dt
		end
		
		n = 1
		while n <= #playermissiles do
			x,y = playermissiles[n].body:getPosition()
			if x < -missileradius or x > WINDOWWIDTH + missileradius or y < -missileradius or y > WINDOWHEIGHT +missileradius then
				playermissiles[n].body:destroy()
				table.remove(playermissiles, n)
				n = n - 1
			end
			n = n + 1
		end
		
		table.insert(lastmousepoints, {mousex,mousey})
		table.remove(lastmousepoints, 1)
		
		if not stopenemies then
			if babymoveslowdown > BABYMOVESLOWDOWN then
				babymoveslowdown = 0
				for i in pairs(enemies.baby) do
					x,y = enemies.baby[i].body:getPosition()
					if x < WINDOWWIDTH and x > 0 and y > 0 and y < WINDOWHEIGHT then
						move_baby(dt)
					end
				end
			else
				babymoveslowdown = babymoveslowdown + dt
			end
			
			move_icy()
		end
		
		playerx,playery = player.body:getPosition()
		for i in pairs(enemies.icy) do
			if enemies.icy[i].missileslowdown > ICYMISSILESLOWDOWN and enemies.icy[i].health > 0 then
				enemies.icy[i].missileslowdown = 0
				xspot,yspot = enemies.icy[i].body:getPosition()
				table.insert(icymissiles,{})
				n = #icymissiles
				icymissiles[n].body = love.physics.newBody(world, xspot,yspot, "dynamic")
				icymissiles[n].shape = love.physics.newPolygonShape(unpack(icymissilepoints))
				icymissiles[n].fixture = love.physics.newFixture(icymissiles[n].body, icymissiles[n].shape)
				
				slope = (yspot-playery)/(xspot-playerx)
				if xspot < playerx then
					rotation = math.atan(slope) + math.rad(0)
				elseif xspot >playerx then
					rotation = math.atan(slope) + math.rad(180)
				end
				
				xspeed = ( (ICYMISSILESPEED^2)/(1+slope^2)  )^.5
				if xspot-playerx >0 then
					xspeed = -math.abs(xspeed)
				end
				yspeed = xspeed*slope
				icymissiles[n].body:setAngle(rotation)
				icymissiles[n].body:setLinearVelocity(xspeed,yspeed)
				icymissiles[n].fixture:setUserData("enemy missile")
			else
				enemies.icy[i].missileslowdown = enemies.icy[i].missileslowdown + dt
			end
			if not enemies.icy[i].portal == false then
				enemies.icy[i].portal = enemies.icy[i].portal - 10
			end
			
		end
		
		for i in pairs(newcoinlist) do
			table.insert(coinlist,{})
			n = #coinlist
			coinlist[n].body = love.physics.newBody(unpack(newcoinlist[i].body))
			coinlist[n].shape = love.physics.newCircleShape(5)
			coinlist[n].fixture = love.physics.newFixture(coinlist[n].body, coinlist[n].shape)	
			coinlist[n].fixture:setUserData("coin")
			coinlist[n].body:setLinearDamping(2)
		end
		newcoinlist = {}
		
		playerx,playery = player.body:getPosition()
		
		for i in pairs(coinlist) do
			xspot,yspot = coinlist[i].body:getPosition()
			xspeed,yspeed = coinlist[i].body:getLinearVelocity()
			if xspot - 5 < 0 then
				coinlist[i].body:setX(5)
				coinlist[i].body:setLinearVelocity(-xspeed, yspeed)
			elseif xspot + 5 > WINDOWWIDTH then
				coinlist[i].body:setX(WINDOWWIDTH-5)
				coinlist[i].body:setLinearVelocity(-xspeed, yspeed)
			end
			if yspot - 5 < 0 then
				coinlist[i].body:setY(5)
				coinlist[i].body:setLinearVelocity(xspeed, -yspeed)
			elseif yspot + 5 > WINDOWHEIGHT then
				coinlist[i].body:setY(WINDOWHEIGHT-5)
				coinlist[i].body:setLinearVelocity(xspeed, -yspeed)
			end
			
			
			if ((playerx-xspot)^2 + (playery-yspot)^2)^.5 < MAGNETRADIUS then
				if playerx-xspot ~= 0 then
					slope = (playery - yspot)/(playerx - xspot)
					xforce = ( (MAGNETFORCE^2)/(1+slope^2)  )^.5
					if playerx < xspot then
						xforce = -math.abs(xforce)
					end
					yforce = xforce*slope
					coinlist[i].body:applyForce(xforce,yforce)
				else
					coinlist[i].body:applyForce(0,MAGNETFORCE)
				end
			end
		end
		
	end
end














function love.draw(dt)	
	love.graphics.push()
	love.graphics.translate(WINDOWWIDTH/2, WINDOWHEIGHT/2)
	love.graphics.scale(1,1)
	love.graphics.translate(-WINDOWWIDTH/2, -WINDOWHEIGHT/2)
	

	love.graphics.setColor(1,1,1)
	love.graphics.draw(backgroundimage, 0,0, 0, .3,.3)
	
	for i in pairs(coinlist) do
		love.graphics.draw(coinimage, coinlist[i].body:getX(),coinlist[i].body:getY(),0,.5,.5)
	end
	love.graphics.setColor(72/255, 160/255, 14/255)
	for category in pairs(enemies) do
		if category == "baby" then
			for i in pairs(enemies[category]) do
				if enemies[category][i].hurt > -ENEMYHURTTIME  and enemies[category][i].health > 0 then
					enemies[category][i].hurt = enemies[category][i].hurt - 1
					
					red = 228 + (ENEMYHURTTIME - math.abs(enemies[category][i].hurt))*3
					green = 102 + (ENEMYHURTTIME - math.abs(enemies[category][i].hurt)) * 17
					blue = 39 + (ENEMYHURTTIME - math.abs(enemies[category][i].hurt)) * 24
					love.graphics.setColor(red/255, green/255, blue/255)
					love.graphics.polygon("fill",   enemies[category][i].body:getWorldPoints(enemies[category][i].shape:getPoints()))
				elseif enemies[category][i].health <= 0 then
					if enemies[category][i].explosiontime > 0 then
						enemies[category][i].explosiontime = enemies[category][i].explosiontime - dt
						if enemies[category][i].explosiontime <= 0 then
							enemies[category][i].body:destroy()
							table.remove(enemies[category],i)
						else -- 302 x 281
							x,y = enemies[category][i].body:getPosition()
							scale = EXPLOSIONSCALE * (EXPLOSIONTIME-enemies[category][i].explosiontime) ^ -.7
							rand = math.random(-1,1)
							left, top = x-.5*302*scale, y-.5*281*scale
							
							love.graphics.setColor(255/255,180/255,50/255)
							--love.graphics.setColor(255/255,120/255,50/255)
							love.graphics.draw(orangeexplosionimage, left, top, 0, scale,scale)
						end
					end
				else		
					love.graphics.setColor(228/255, 102/255, 39/255)
					love.graphics.polygon("fill",   enemies[category][i].body:getWorldPoints(enemies[category][i].shape:getPoints()))
				end
				
			end
		elseif category == "icy" then
			for i in pairs(enemies[category]) do
				if enemies[category][i].hurt > -ENEMYHURTTIME  and enemies[category][i].health > 0 then
					enemies[category][i].hurt = enemies[category][i].hurt - 1
					
					red = 0 + (ENEMYHURTTIME - math.abs(enemies[category][i].hurt))*28
					green = 162 + (ENEMYHURTTIME - math.abs(enemies[category][i].hurt)) * 10
					blue = 232 + (ENEMYHURTTIME - math.abs(enemies[category][i].hurt)) * 2
					love.graphics.setColor(red/255, green/255, blue/255)
					love.graphics.polygon("fill",   enemies[category][i].body:getWorldPoints(enemies[category][i].shape:getPoints()))
				elseif enemies[category][i].health <= 0 then
					if enemies[category][i].explosiontime > 0 then
						enemies[category][i].explosiontime = enemies[category][i].explosiontime - dt
						if enemies[category][i].explosiontime <= 0 then
							enemies[category][i].body:destroy()
							table.remove(enemies[category],i)
						else -- 302 x 281
							x,y = enemies[category][i].body:getPosition()
							scale = EXPLOSIONSCALE * (EXPLOSIONTIME-enemies[category][i].explosiontime) ^ -.7
							rand = math.random(-1,1)
							left, top = x-.5*302*scale, y-.5*281*scale
							
							love.graphics.setColor(1,1,1)
							love.graphics.draw(blueexplosionimage, left, top, 0, scale,scale)
						end
					end
				else
					red = math.sqrt(enemies[category][i].health/ICYHEALTH) *23
					green = math.sqrt(enemies[category][i].health/ICYHEALTH) * 186
					blue = math.sqrt(enemies[category][i].health/ICYHEALTH) * 255
					love.graphics.setColor(red/255,green/255,blue/255)
					love.graphics.polygon("fill",   enemies[category][i].body:getWorldPoints(enemies[category][i].shape:getPoints()))
				end
				
			end
		end
	end
	
	if false then
	for i in pairs(enemies.icy) do
		if enemies.icy[i].direction then
			xpos,ypos = enemies.icy[i].body:getPosition()
			if enemies.icy[i].direction == "left" then
				if math.abs(xpos - portalplace) < enemies.icy[i].portalplace[1] then
					love.graphics.setColor(0.5,0.5,0.5,(enemies.icy[i].portalplace[1]-math.abs(xpos-portalplace))/255)
					if ypos < WINDOWHEIGHT/2 then
						love.graphics.draw(portalimage, portalplace, ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, portalplace,ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
				if math.abs(xpos - (WINDOWWIDTH - portalplace)) < enemies.icy[i].portalplace[1] then
					love.graphics.setColor(0.5,0.5,0.5,(enemies.icy[i].portalplace[1]-math.abs(xpos - (WINDOWWIDTH - portalplace)))/255)
					if ypos < WINDOWHEIGHT/2 then
						love.graphics.draw(portalimage, WINDOWWIDTH - enemies.icy[i].portalplace[1], ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, WINDOWWIDTH - enemies.icy[i].portalplace[1], ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
			elseif enemies.icy[i].direction == "right" then
				if math.abs(xpos - (WINDOWWIDTH - portalplace)) < 255 then
					love.graphics.setColor(0.5,0.5,0.5,(255-math.abs(xpos - (WINDOWWIDTH - portalplace)))/255)
					if ypos < WINDOWHEIGHT/2 then
						love.graphics.draw(portalimage, WINDOWWIDTH - portalplace, ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, WINDOWWIDTH - portalplace, ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
				if math.abs(xpos - portalplace) < 255 then
					love.graphics.setColor(0.5,0.5,0.5,(255-math.abs(xpos-portalplace))/255)
					if ypos < WINDOWHEIGHT/2 then
						love.graphics.draw(portalimage, portalplace, ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, portalplace,ypos, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
			elseif enemies.icy[i].direction == "up" then
				if math.abs(ypos - portalplace) < 255 then
					love.graphics.setColor(0.5,0.5,0.5,(255-math.abs(ypos-portalplace))/255)
					if xpos < WINDOWWIDTH/2 then
						love.graphics.draw(portalimage, xpos, portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, xpos, portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
				if math.abs(ypos - (WINDOWHEIGHT - portalplace)) < 255 then
					love.graphics.setColor(0.5,0.5,0.5,(255-math.abs(ypos - (WINDOWHEIGHT - portalplace)))/255)
					if xpos < WINDOWWIDTH/2 then
						love.graphics.draw(portalimage, xpos, WINDOWHEIGHT - portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, xpos, WINDOWHEIGHT - portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
			elseif enemies.icy[i].direction == "down" then
				if math.abs(ypos - (WINDOWHEIGHT - portalplace)) < 255 then
					love.graphics.setColor(0.5,0.5,0.5,(255-math.abs(ypos - (WINDOWHEIGHT - portalplace)))/255)
					if xpos < WINDOWWIDTH/2 then
						love.graphics.draw(portalimage, xpos, WINDOWHEIGHT - portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, xpos, WINDOWHEIGHT - portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
				if math.abs(ypos - portalplace) < 255 then
					love.graphics.setColor(0.5,0.5,0.5,(255-math.abs(ypos-portalplace))/255)
					if xpos < WINDOWWIDTH/2 then
						love.graphics.draw(portalimage, xpos, portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					else
						love.graphics.draw(portalimage, xpos, portalplace, 0, portalimagescale,portalimagescale,  portalimagewidth/2, portalimageheight/2)
					end
				end
			end
		end
	end
	end
		
	
	for i in pairs(playermissiles) do
		x,y = playermissiles[i].body:getPosition()
		love.graphics.setColor(0,0,0)
		love.graphics.circle("fill", x,y, playermissiles[i].shape:getRadius()*1.1)
		
		love.graphics.setColor(0,130/255,185/255)		
		love.graphics.circle("fill", x,y, playermissiles[i].shape:getRadius())
		
	end
	
	love.graphics.setColor(1, 1, 1)
	for i in pairs(icymissiles) do
		list = {icymissiles[i].body:getWorldPoints(icymissiles[i].shape:getPoints())}
		xcorn, ycorn = list[3], list[4]
		if false then
			love.graphics.polygon("fill", icymissiles[i].body:getWorldPoints(icymissiles[i].shape:getPoints()))
		end
		
		love.graphics.draw(icymissileimage,xcorn,ycorn, icymissiles[i].body:getAngle()+math.rad(90), icymissileimagescale, icymissileimagescale )
	end
	
	
	if COOLDOWNTIME > 0 then
		x = 0+ COOLDOWNTIME ^.5 * math.floor(188/1.41)*math.random()
		playercolor = {0,150/255,0,250/255}
	else
		playercolor = {0, 1, 0}
	end
	

	for i in pairs(playerlaunchers) do	
		love.graphics.setColor(unpack(playercolor))
		love.graphics.polygon("fill", playerlaunchers[i].body:getWorldPoints(playerlaunchers[i].shape:getPoints()))
		love.graphics.setColor(0,0,0)
		love.graphics.polygon("line",playerlaunchers[i].body:getWorldPoints(playerlaunchers[i].shape:getPoints()))
	end
	
	love.graphics.setColor(unpack(playercolor))
	x,y = player.body:getPosition()
	love.graphics.circle("fill", x,y,  playerradius)
	
	love.graphics.setColor(0,0,0)
	love.graphics.circle("line", x,y,  playerradius)
	
	if player.frozentime > 0 then
		green = 55
		blue = 255
		alpha = (player.frozentime)*30
		if alpha > 255 then
			alpha = 255
		end
		love.graphics.setColor(0,green/255, blue/255, alpha/255)
		
		for i in pairs(playerlaunchers) do		
			love.graphics.polygon("fill", playerlaunchers[i].body:getWorldPoints(playerlaunchers[i].shape:getPoints()))
		end

		x,y = player.body:getPosition()
		love.graphics.circle("fill", x,y,  playerradius)
		if not paused and not dead then
			player.frozentime = (player.frozentime^.5 - dt)^2
		end
		love.graphics.print(player.frozentime,50,80)
		if player.frozentime < 0.1 then
			player.frozentime = 0
		end
	end
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(#icymissiles, 100,100)
	
	love.graphics.setColor(17/255,237/255,6/255)
	for i in pairs(box) do
		love.graphics.polygon("fill", box[i].body:getWorldPoints(box[i].shape:getPoints()))
	end
	
	if false then
		list = {}
		for i in pairs(playermissiles) do
			x,y = playermissiles[i].body:getPosition()
			table.insert(list, x)
			table.insert(list, y)
		end
		
		if #playermissiles > 1 then
			love.graphics.setColor(255/255,87/255, 37/255)
			love.graphics.line(unpack(list))
		end
	end
	
	
	--love.graphics.setColor(17,237,6) Nice green
	love.graphics.setColor(100/255,6/255,217/255)
	love.graphics.rectangle("fill", 0,WINDOWHEIGHT, WINDOWWIDTH, HUDHEIGHT)
	
	love.graphics.setColor(10/255,16/255,48/255)
	n = 0
	top1 = WINDOWHEIGHT + 4
	column1 = 1
	while n <= MAXPLAYERHEALTH-1 do	
		if column1 > 6 then
			top1 = top1 + 23
			column1 = 1
		end
		
		love.graphics.rectangle("fill", 6 + column1 * (HEALTHBARWIDTH + 10), top1, HEALTHBARWIDTH+8,  20)		
		n = n + 1
		column1 = column1 + 1
	end
	
	love.graphics.setColor(255/255,16/255,48/255)
	n = 0
	top = WINDOWHEIGHT + 8
	column = 1
	while n <= PLAYERHEALTH-1 do
		if column > 6 then
			top = top + 23
			column = 1
		end
		love.graphics.rectangle("fill", 10 + column * (HEALTHBARWIDTH + 10), top	, HEALTHBARWIDTH,  12)		
		n = n + 1
		column = column + 1
	end
	
	
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(basicFont)
	
	if MAXPLAYERHEALTH/6 ~= math.floor(MAXPLAYERHEALTH/6) then
		left = 6 + column1 * (HEALTHBARWIDTH + 10) +3
		top1 = top1 - 6
	else
		left = (6*(HEALTHBARWIDTH+5))/2 +38
		top1 = top1 + 16
	end
	
	love.graphics.setFont(scoreFont)
	love.graphics.print(PLAYERHEALTH, left, top1)
	love.graphics.pop()

	
	fps = love.timer.getFPS()
	
	love.graphics.setFont(moneyFont)
	love.graphics.print(fps, 10,10)
	
	love.graphics.setColor(248/255,217/255,1/255)
	love.graphics.print("$ " .. cash, WINDOWWIDTH - 100, WINDOWHEIGHT + 20)

	--[[
	if enemies.icy[1] then
		if enemies.icy[1].portal == false then 
			x = "false"
		else
			x = enemies.icy[1].portal
		end
		love.graphics.print(x, 10,100)
		if section then
		love.graphics.print(section, 10,130)
		end
		
	end ]]
	
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
	  next_time = cur_time
	  return
	end
	love.timer.sleep((next_time - cur_time))

	
end


function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
		timing = love.timer.getTime()

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end

		curtime = love.timer.getTime()
		
		if curtime-timing < 1/40 then
			love.timer.sleep(1/40 - (curtime-timing))
		end
	end
end
