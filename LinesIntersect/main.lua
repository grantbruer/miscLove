
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
	
	point = {x=500,y=100}
	line = {250,350,  550,300}
	lineslope = (line[2]-line[4])/(line[1]-line[3])
	lineyinter = line[2] - lineslope * line[1]
	
	rectangle1 = {x=0,y=0,width=30,height=30}
	-- rectangle2 = {x=100,y=400,width=300,height=300}
	speed = 1	
end


function love.update()
	--[
	if love.keyboard.isDown('a') then
		rectangle1.x = rectangle1.x - speed
	end
	
	if love.keyboard.isDown('d') then
		rectangle1.x = rectangle1.x + speed
	end
	
	if love.keyboard.isDown('w') then
		rectangle1.y = rectangle1.y - speed
	end
	
	if love.keyboard.isDown('s') then
		rectangle1.y = rectangle1.y + speed
	end
	--]]
	
	if love.keyboard.isDown('left') then
		point.x = point.x - speed
	end
	
	if love.keyboard.isDown('right') then
		point.x = point.x + speed
	end
	
	if love.keyboard.isDown('up') then
		point.y = point.y - speed
	end
	
	if love.keyboard.isDown('down') then
		point.y = point.y + speed
	end
	
	love.timer.sleep(1/160)
end


function love.draw()
--[
	love.graphics.setColor(250,0,0)
	love.graphics.line(0,lineyinter, 800, 800*lineslope + lineyinter)
	love.graphics.setColor(100,200,255)
	love.graphics.line(unpack(line))
	
	local length = (rectangle1.x - point.x)^2 + (rectangle1.y-point.y)^2
	love.graphics.setLineWidth(1 + 150000/length)
	love.graphics.setColor(255,255,255)
	love.graphics.line(rectangle1.x,rectangle1.y, point.x,point.y)
	
	love.graphics.setLineWidth(1)
	love.graphics.setColor(220,0,0)
	love.graphics.line(rectangle1.x,rectangle1.y, point.x,point.y)
	
	
	love.graphics.setColor(255,255,255)
	x1,x2,x3,x4,y1,y2,y3,y4 = linesIntersect(rectangle1.x,rectangle1.y,point.x,point.y, line[1],line[2],line[3],line[4] )
	
	if type(x2) == 'number' and type(x3) == 'number' then
		love.graphics.setColor(100,100,100)
		love.graphics.circle("fill", x2,x3, 5)
	end
	love.graphics.print("X1: " .. tostring(x1),300,10)
	love.graphics.print("X2: " .. tostring(x2),300,30)
	love.graphics.print("X3: " .. tostring(x3),300,50)
	love.graphics.print("X4: " .. tostring(x4),300,70)
	
	love.graphics.print("Y1: " .. tostring(y1),375,10)
	love.graphics.print("Y2: " .. tostring(y2),375,30)
	love.graphics.print("Y3: " .. tostring(y3),375,50)
	love.graphics.print("Y4: " .. tostring(y4),375,70)


	love.graphics.print("R1 x: " .. tostring(rectangle1.x),300,110)
	love.graphics.print("R1 y: " .. tostring(rectangle1.y),300,130)
	love.graphics.print("P x: " .. tostring(point.x),300,150)
	love.graphics.print("P y: " .. tostring(point.y),300,170)


	love.graphics.print("L1: " .. tostring(line[1]),375,110)
	love.graphics.print("L2: " .. tostring(line[2]),375,130)
	love.graphics.print("L3: " .. tostring(line[3]),375,150)
	love.graphics.print("L4: " .. tostring(line[4]),375,170)

	--love.graphics.print(tostring(x and y), 350,18)
	
	love.graphics.rectangle('line', line[1],line[2], line[3]-line[1], line[4]-line[2])
	
--]]

--[[
	love.graphics.setColor(200,0,255)
	love.graphics.rectangle("fill", rectangle1.x,rectangle1.y,rectangle1.width,rectangle1.height)
	
	love.graphics.setColor(100,200,0)
	love.graphics.rectangle("fill", rectangle2.x,rectangle2.y,rectangle2.width,rectangle2.height)
	
	
	collide = (rectangle1.x < rectangle2.x + rectangle2.width and rectangle2.x < rectangle1.x + rectangle1.width and rectangle1.y < rectangle2.y + rectangle2.height and rectangle2.y < rectangle1.y + rectangle1.height)
	
	love.graphics.print(tostring(collide),100,10)
--]]
end


function love.keypressed(key)
	if  key == 'escape' then
		love.event.quit()
	end

end
function linesIntersect(ax,ay,bx,by, ox,oy,px,py)
	
	
	if (ax > ox and ax > px and bx > ox and bx > px) or (ax < ox and ax < px and bx < ox and bx < px) or (ay > oy and ay > py and by > oy and by > py) or (ay < oy and ay < py and by < oy and by < py) then
		return false
	elseif true then
		--[[
		
		local aprop = (ax - ox)/(ox-px)
		aabove = ay < oy + (oy-py)*aprop
		
		local bprop = (bx - ox)/(ox-px)
		babove = by < oy + (oy-py)*bprop
	
		return aabove ~= babove, aabove,babove, aprop, bprop
		
		--]] 
		
		--Condensed--		
		return ((ay < oy + (oy-py)*(ax - ox)/(ox-px)) ~= (by < oy + (oy-py)*(bx - ox)/(ox-px))) and ((oy < ay + (ay-by)*(ox - ax)/(ax-bx)) ~= (py < ay + (ay-by)*(px - ax)/(ax-bx))), aabove,babove, aprop, bprop
	else
		-- y = mx + b
		-- b = y - mx
		local abslope = (ay-by)/(ax-bx)
		local abyinter = ay - abslope*ax
		
		local opslope = (oy-py)/(ox-px)
		local opyinter = oy - opslope*ox
		
		if abslope == opslope then
			return abyinter == opyinter
		else
			--  abslope * x + abyinter = opslope * x + opyinter
			local solux = (opyinter-abyinter)/(abslope-opslope)
			local soluy = abslope * solux + abyinter
			return ((solux > ox and solux < px) or (solux > px and solux < ox)) and ((solux > ax and solux < bx) or (solux < ax and solux > bx)), solux, soluy
		end
		
	end
	
	
	
	--[[
	ox + (ox-px) * prop == ax
	prop == (ax - ox)/(ox-px)
	oy + (oy-py) * prop =? ay
	
	linex = ax
	liney = oy + (oy-py)*prop
	--]]
	
	
	
	
	x1 =  (ax < ox and bx > px)
	x2 =  (ax < px and bx > ox)
	x3 =  (ax > ox and bx < px)
	x4 =  (ax > px and bx < ox)
	--x =  (ax < ox and bx > px) or (ax < px and bx > ox) or (ax > ox and bx < px) or (ax > px and bx < ox)
	--y =  (ay < oy and by > py) or (ay < py and by > oy) or (ay > oy and by < py) or (ay > py and by < oy)
	y1 =  (ay < oy and by > py)
	y2 =  (ay < py and by > oy)
	y3 =  (ay > oy and by < py)
	y4 =  (ay > py and by < oy)
	return x1,x2,x3,x4,y1,y2,y3,y4
end

collision = {}

function collision.polygons(array1,array2)
	local i = 1
	while i <= #array1-3 do
			
		local n = 1
		while n <=	# array2-3  do
			if collision.lineSegments(array1[i],array1[i+1],array1[i+2], array1[i+3], array2[n],array2[n+1],array2[n+2], array2[n+3]) then
				return true
			end
			n = n + 4
		end
		
		i = i + 4
	end
	
	return false
end
