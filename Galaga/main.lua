
local major, minor, revision, codename = love.getVersion()
print(string.format("Using compatibility profile for version %d.%d.%d", major, minor, revision))
local version10 = (major == 0 and minor == 10)
if not version10 then
    -- Convert colors from [0,255] to [0,1]
    local oldSetColor = love.graphics.setColor
    function love.graphics.setColor(r, g, b, a)
        if type(r) == 'table' then
            g = r[2]
            b = r[3]
            a = r[4]
            r = r[1]
        end
        g = g/255
        b = b/255
        a = a and a/255
        r = r/255
        oldSetColor(r,g,b,a)
    end
end

function love.load()

	d = 0
	paused = false 
	clear = true
	present = true
	
	player = {}
	
	player.x = 100
	player.y = 0
	player.pic = love.graphics.newImage("Aaron.png")
	player.speed = 800
	
	player.picwidth = 66
	player.picheight = 64
	
	player.picActualWidth = player.pic:getWidth()
	player.picActualHeight = player.pic:getHeight()
	
	player.picxscale = player.picwidth/player.picActualWidth
	player.picyscale = player.picheight/player.picActualHeight
	
	
	window = {}
	window.width, window.height = love.graphics.getDimensions()

	spaceimage = love.graphics.newImage("my star background.png")
	
	missiles = {}
	missileA = {} -- A stands for attributes
	missileA.width = 6
	missileA.height = 15
	missileA.speed = 850
	missileA.delay = 0.1
	missileA.timer = 0
	missileA.damage = 20
	
	missileA.image = love.graphics.newImage("missile.png")
	missileA.imagewidth = missileA.image:getWidth()
	missileA.imageheight = missileA.image:getHeight()
	
	laserwidth = 55 --22
	laserdamage = 30 --per second
	laserspace = 15
	laserpic = {}
	laserpic.image = love.graphics.newImage("laser.png")
	laserpic.width = laserpic.image:getWidth()
	laserpic.height = laserpic.image:getHeight()
	
	laserspacepic = {}
	laserspacepic.image = love.graphics.newImage("laserspace.png")
	laserspacepic.width = laserspacepic.image:getWidth()
	laserspacepic.height = laserspacepic.image:getHeight()
	
	enemies = {}
	enemypic = {}
	enemypic.red = love.graphics.newImage("red enemy2.png")
	enemypic.width = enemypic.red:getWidth()
	enemypic.height = enemypic.red:getHeight()
	
	enemyWidth = 42
	enemyHeight = 36
	enemySpeed = 300
	enemyHealth = 6
	enemyMoveRadius = 60
	enemyMeanderSpeed = 25
	
	spf = 1/60
	curtime = 0
	lasttime = 0
	
	enemyformation = {}
	enemyformation.pattern = {}
	
	local length, height = 14,4
	enemyformation.left, enemyformation.right = 100, window.width-100
	enemyformation.top, enemyformation.bottom = 50, window.height/2-enemyHeight
	
	enemyformation.xoff = 0
	enemyformation.yoff = 0
	enemyformation.xspeed = 0
	for gridy = 0,height-1 do
		local y = gridy/height * (enemyformation.bottom - enemyformation.top) + enemyformation.top

		for gridx = 0, length-1 do 
			local x = gridx/length * (enemyformation.right-enemyformation.left) + enemyformation.left
			table.insert(enemyformation.pattern, {x=x,y=y})
		end
	end
	
end




function fireMissile(x,y, xspeed,yspeed)
	table.insert(missiles,{})
	local n = #missiles
	missiles[n].xspeed = xspeed
	missiles[n].yspeed = yspeed
	
	missiles[n].y = y
	missiles[n].x = x
	
	local rand = 2 --math.random(1,4)
	if rand == 1 then
		missiles[n].color = {200,0,0,nil}
	elseif rand == 2 then
		missiles[n].color = {0,200,0,nil}
	elseif rand == 3 then
		missiles[n].color = {0,0,200,nil}
	else
		missiles[n].color = {200,200,0,nil}
	end
end

function updateMissiles(dt)
	for i,v in ipairs(missiles) do
		if v.destroy then
			table.remove(missiles,i)
		else
			v.x = v.x + v.xspeed*dt
			v.y = v.y + v.yspeed*dt
			if v.x > window.width or v.x + missileA.width < 0 or v.y + missileA.height*3 < 0 or v.y - missileA.height*3 > window.height then
				v.destroy = true
			end
		end
	end

end

function drawMissiles(dt)
	for i,v in ipairs(missiles) do
		love.graphics.setColor(255,255,0,155)
		love.graphics.draw(missileA.image, v.x-v.xspeed*0.01,v.y - v.yspeed*0.01,0, missileA.width/missileA.imagewidth, missileA.height/missileA.imageheight)
		
		love.graphics.setColor(255,255,0)
		love.graphics.draw(missileA.image, v.x,v.y,0, missileA.width/missileA.imagewidth, missileA.height/missileA.imageheight)		
	end
end


function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key =='p' then
		paused = not paused
	elseif key == 'c' then
		clear = not clear
	elseif key == 'l' then
		present = not present
	end
end


                                                    
function love.update(dt)
	curtime = love.timer.getTime()
	
	if not paused then
		if love.keyboard.isDown("a") then
			player.x = player.x - player.speed*dt
		end
		if love.keyboard.isDown("d") then
			player.x = player.x + player.speed*dt
		end
		--[[
		if love.keyboard.isDown("w") then
			player.y = player.y - player.speed
		end
		if love.keyboard.isDown("s") then
			player.y = player.y + player.speed
		end
		--]]
		if player.y < window.height-player.picheight*1.25 then
			player.y = window.height -player.picheight*1.25
		elseif player.y > window.height - player.picheight/2 then
			player.y = window.height - player.picheight/2
		end
		
		if player.x < 0 then 
			player.x = 0
		elseif player.x + player.picwidth > window.width then
			player.x = window.width - player.picwidth
		end
		
		
		--
		if love.keyboard.isDown("space") then
			if missileA.timer > missileA.delay then
				missileA.timer = 0
				fireMissile(player.x + player.picwidth/2-missileA.width/2, player.y+player.picwidth*0.1,0,-missileA.speed)
			end
		end
		missileA.timer = missileA.timer + dt
		
		updateMissiles(dt)
		
		if math.random() < 1 and #enemyformation.pattern > 0 then
			local xs = 5--math.random(-5,5)
			local ys = 5--math.random(-5,5)
			local width = enemyWidth --30
			local height = enemyHeight--40
			local i = math.random(1,#enemyformation.pattern)
			spawnEnemy(10,-200,xs,ys,width,height, enemyformation.pattern[i].x, enemyformation.pattern[i].y)
			table.remove(enemyformation.pattern,i)
		end
	
		updateEnemies(dt)
		--]]
	end
	
	
	
	--[[
	
	for i,v in pairs(enemies) do
		v.x = v.x + v.xspeed
		v.y = v.y + v.yspeed
		if v.x < 0 then
			v.x = 0
			v.xspeed = math.abs(v.yspeed)
		elseif v.x + 100 > window.width then
			v.x = window.width -100
			v.xspeed = -math.abs(v.xspeed)
		elseif v.y < 0 then
			v.y = 0
			v.yspeed = math.abs(v.yspeed)
		elseif v.y > window.height/2-200 then
			v.y = window.height/2 - 200
			v.yspeed = -math.abs(v.yspeed)
		end
	end
	
	
	local rand = math.random()
	if rand < 0.02 then
		for i,v in pairs(enemies) do
			local xspeed, yspeed = math.random(-10,10),math.random(-10,10)
			v.xspeed = xspeed
			v.yspeed = yspeed
		end
	elseif rand < 0.2 then
		for i,v in pairs(enemies) do
			fireMissile(v.x+enemypic.width/2,v.y+enemypic.height*0.8,0, missileA.speed)
		end
	end
	love.graphics.setCaption(love.timer.getFPS())
	
	--]]
	
	
	
	love.window.setTitle(  love.timer.getFPS() )
	
	
end


function love.draw(dt)
	--[[
	if #missiles == 0 then
		love.graphics.setColor(255,255,255)
	end
	--]]
	love.graphics.setColor(255,255,255)
	love.graphics.draw(spaceimage,0,0)
	
	love.graphics.setBackgroundColor(100,0,0)

	love.graphics.setColor(255,255,255)
	love.graphics.draw(player.pic, player.x, player.y, 0, player.picxscale,player.picyscale)

	
	
	drawEnemies()
	
	if not paused then
		drawLaser()
	end
	drawMissiles(dt)
	
	
	--[[
	for i,v in pairs(enemies) do
		love.graphics.setColor(255,255,104)
		love.graphics.circle("fill", v.xdest, v.ydest, 2)
		
		love.graphics.setColor(0,255,255)
		love.graphics.circle("fill", v.tempxdest, v.tempydest, 2)
	end
	--]]
	
	love.graphics.setColor(255,255,255)
	love.graphics.print(#enemies, 10,10)
	
	lasttime = love.timer.getTime()
	frametime = lasttime - curtime
	if frametime < spf then
		--love.timer.sleep(spf - frametime)
	end

end


function drawLaser()
	if love.mouse.isDown(1) then
	--[[
		local alpha = 55
		local width = laserwidth
		for i=0,10 do
			love.graphics.setColor(100,255,0,alpha)
			love.graphics.rectangle("fill", player.x + player.picwidth/2 - width/2, 0, width, player.y-laserspace)
			alpha = alpha + i
			width = width - laserwidth/11
		end
		
		alpha = 105
		width = laserwidth
		local height = laserspace/10
		local top = player.y - laserspace
		for i=0,10 do
			love.graphics.setColor(100,255,0,alpha)
			love.graphics.rectangle("fill", player.x + player.picwidth/2 - width/2, top, width,height)
			alpha = alpha + 15
			width = width - laserwidth/11
			top = top + height
		end
	--]]
		love.graphics.setColor(0,255,0)
		love.graphics.draw(laserpic.image,player.x + player.picwidth/2 - laserwidth/2, 0,0, laserwidth/laserpic.width, (player.y-laserspace)/laserpic.height)
		
		love.graphics.draw(laserspacepic.image,player.x + player.picwidth/2 - laserwidth/2,player.y-laserspace, 0, laserwidth/laserspacepic.width, laserspace/laserspacepic.height)
		
	end
end


function spawnEnemy(x,y,xspeed,yspeed,width,height, xdest, ydest)
	if xdest then
		ydis = ydest - y
		xdis = xdest - x
		angle = math.atan2(ydis, xdis)
		yspeed = math.sin(angle) * enemySpeed
		xspeed = math.cos(angle) * enemySpeed
	end
	
	table.insert(enemies, {x=x, y=y, xspeed=xspeed, yspeed=yspeed,width=width, height=height, xdest = xdest, ydest = ydest,health = enemyHealth})
end

function updateEnemies(dt)
	local dx = 0
	
	enemyformation.xoff = enemyformation.xoff + enemyformation.xspeed
	if enemyformation.right + enemyformation.xoff + enemyWidth > window.width then
		enemyformation.xspeed = -math.abs(enemyformation.xspeed)
	elseif enemyformation.left + enemyformation.xoff < 0 then
		enemyformation.xspeed = math.abs(enemyformation.xspeed)
	end
	for i,v in ipairs(enemies) do
	
		if math.random() < 0.02 then
			-- fireMissile(v.x+v.width/2-missileA.width/2,v.y+enemypic.height*0.8,0, missileA.speed)
		end
		
		v.x = v.x + v.xspeed*dt
		v.y = v.y + v.yspeed*dt
		
		
		if (v.x - v.xdest) * v.xspeed >= 0 or (v.y - v.ydest) * v.yspeed >= 0 then
			if (v.x-v.xdest)^2 + (v.y-v.ydest)^2 > enemyMoveRadius then
				local curang = math.atan2(v.yspeed,v.xspeed)
				local ang = math.random() * math.pi + curang
				v.xspeed = math.cos(ang)*enemyMeanderSpeed
				v.yspeed = math.sin(ang)*enemyMeanderSpeed
				if enemyMeanderSpeed == 0 then
					v.x = v.xdest
					v.y = v.ydest
				end
			end
		end
			
		--v.yspeed = math.sin(angle)*14
		--v.xspeed = math.cos(angle)*14
		
		--[[
		if v.y + v.height > window.height*0.5 then
			v.y = 0.5 * window.height - v.height
			v.yspeed = -v.yspeed
		elseif v.y < 0 then
			v.y = 0
			v.yspeed = -v.yspeed
		end
		
		if v.x +v.width > window.width then
			v.x = window.width - v.width
			v.xspeed = -v.xspeed
		elseif v.x < 0 then
			v.x = 0
			v.xspeed = -v.xspeed
		end
		--]]
		for a,b in pairs(missiles) do
		
			if collision.rectangles(v.x,v.y,v.width,v.height,  b.x,b.y, missileA.width, missileA.height) then
				v.health = v.health - missileA.damage
				table.remove(missiles,a)				
			end
			
		end
		
		if love.mouse.isDown(1) and collision.rectangles(v.x,v.y,v.width,v.height,  player.x+player.picwidth/2-laserwidth/2,0,laserwidth,player.y ) then
			-- local left = math.abs(player.x+player.picwidth/2+laserwidth/2 - v.x-v.width)
			-- local right = math.abs(v.x- (player.x+player.picwidth/2 - laserwidth/2))
			-- local minl = math.abs(laserwidth - v.width)/2
			-- minl = minl * minl
			v.health = v.health - laserdamage*dt
		end
		
		if v.health <= 0 then
			table.insert(enemyformation.pattern, {x = v.xdest, y =v.ydest})
			table.remove(enemies,i)
		end
	end

end

function drawEnemies()
	for i,v in pairs(enemies) do
		
		local red= v.health/enemyHealth*100 + 155
		love.graphics.setColor(red,red,red,red)
		love.graphics.draw(enemypic.red, v.x,v.y,0, v.width/enemypic.width, v.height/enemypic.height)
		
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle("fill", v.x,v.y+v.width*0.9, v.width,6)
		
		love.graphics.setColor(200,0,0)
		love.graphics.rectangle("fill", v.x+2,v.y+v.width*0.9+1, (v.width-4) * v.health/enemyHealth,4)
		
		love.graphics.setColor(100,100,255)
		-- love.graphics.circle("fill", v.xdest,v.ydest,enemyMoveRadius^0.5)
		
		love.graphics.setColor(255,255,100)
		-- love.graphics.circle("fill", v.x,v.y,2)
		
		v.xdest = v.xdest - enemyformation.xoff
		v.ydest = v.ydest - enemyformation.yoff
	end
	

end


collision = {}
function collision.rectangles(left1,top1,width1,height1,left2,top2,width2,height2 )
	return (left1 + width1 > left2 and left2 + width2 > left1 and top1 + height1 > top2 and top2 + height2 > top1)
end


function math.randomsign()
	if math.random() < 0.5 then
		return 1
	else
		return -1
	end
end









function love.run()

    math.randomseed(os.time())
    math.random() math.random()

    if love.load then love.load(arg) end

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
		timing = love.timer.getTime()
        -- Call update and draw
		
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
		if not clear then
			love.graphics.present()
		end
        if love.graphics then
			if clear then
				love.graphics.clear()
			end
            if love.draw then love.draw(dt) end
        end

        --if love.timer then love.timer.sleep(0.001) end
        if love.graphics and present then love.graphics.present() end
		curtime = love.timer.getTime()
		
		if curtime-timing < 1/40 then
			-- love.timer.sleep(1/40 - (curtime-timing))
		end
		
    end

end












