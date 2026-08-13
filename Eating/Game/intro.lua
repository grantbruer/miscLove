intro = {}

function intro.load()
	logopic = love.graphics.newImage('Assets/Images/logo.png')
	function  love.keypressed(key) 
		if key == 'escape' then
			state = 'quit'
		elseif key == 'space' then
			state = 'game'
		end
	end
	
	polygon = {100,100,  250,50,  500,200,  400,500, 50,200}
	
	local left,right,width,height = collision.getBoundingBox(polygon)
	boundingbox = {left,right,width,height}
end

function intro.update(dt)

end

function intro.draw()
	--love.graphics.draw(logopic, 0,0)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill",0,0,800,600)
	
	love.graphics.setFont(blurryfont)
	love.graphics.print("The best time to wear a striped sweater is all the time.",10,10)
	love.graphics.print("ABCDEFGHIJKLMNOPQRSTUVWXYZ",10,30)
	love.graphics.print("1234567890",10,50)
	love.graphics.print("!@#$%^&*()",10,70)
	love.graphics.print("-=[]\\;',./",10,90)
	love.graphics.print("Grant's Game",10,110)
	
	love.graphics.setColor(200,200,200)
	love.graphics.rectangle("fill", boundingbox[1],boundingbox[2],boundingbox[3],boundingbox[4])
	
	love.graphics.setLineWidth(5)
	love.graphics.setColor(255,0,0)
	love.graphics.polygon("fill", unpack(polygon))
end


function intro.run()

    math.randomseed(os.time())
    math.random() math.random()

    if intro.load then intro.load(arg) end

    local dt = 0

    -- Main loop time.
    while state == 'intro' do
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
        if intro.update then intro.update(dt) end -- will pass 0 if love.timer is disabled
        if love.graphics then
            if intro.draw then intro.draw() end
        end

        if love.timer then love.timer.sleep(0.001) end
        if love.graphics then love.graphics.present() end
		if clearscreen then
			love.graphics.clear()
		end
			
    end

end
