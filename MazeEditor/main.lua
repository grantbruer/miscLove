

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

require 'lib/camera'
require 'lib/New Tables'
require 'lib/collision'
require 'level2'
require 'level2nodes'
grid = {}
function love.load()
	
	window = {}
	window.width,window.height = love.graphics.getWidth(), love.graphics.getHeight()
	
	editor = {}
	editor.x,editor.y = 0,0
	editor.state = "ready"
	editor.offsetx = 0
	editor.offsety =0
	editor.selected = nil

	grid.size = 50
	grid.show = false
	
	level = {}
	level.blocks = blocks
	level.nodes = nodes
	
	for i,v in pairs(level.nodes) do
		if v.radius then
			v.radius = nil
		end
		if not v.connections then
			v.connections = {}
		end
	end
	--level.blockss = table          	                           																																																																																																											tostring(stringtotable(grant.table.load('level.txt')))
	camera.load()
end


function love.update(dt)
	camera.update(dt)
	mousex,mousey = love.mouse.getPosition()
	wmousex,wmousey = camera.getWorldPoint(mousex,mousey)
	if editor.state == 'adding' then
		level.blocks[1].width,level.blocks[1].height = math.round(wmousex,grid.size) - level.blocks[1].x , math.round(wmousey,grid.size) - level.blocks[1].y
	elseif editor.selected and editor.state == 'moving' then
		editor.selected.x = -editor.offsetx + math.round(wmousex,grid.size)
		editor.selected.y = -editor.offsety + math.round(wmousey,grid.size)
	end
end


function love.draw()
	mousex,mousey = love.mouse.getPosition()
	wmousex,wmousey = camera.getWorldPoint(mousex,mousey)
	
	camera.set()
		
		if grid.show then
			grid.draw()
		end
		
		love.graphics.setColor(220,0,0)
		love.graphics.circle("fill", 0,0,10)
		love.graphics.setColor(100,100,255)
		
		love.graphics.setLineWidth(2)
		for i,v in pairs(level.blocks) do
			love.graphics.setColor(100,100,255)
			love.graphics.rectangle("fill", v.x,v.y,v.width,v.height)
			
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", v.x,v.y,v.width,v.height)
		end
		
		for i,v in pairs(level.nodes) do
			love.graphics.setColor(255,100,255)
			love.graphics.circle("fill", v.x,v.y,10)
		end
		
		if editor.state == 'connecting' then
			love.graphics.setColor(255,255,255)
			love.graphics.line(wmousex,wmousey, editor.selected.x, editor.selected.y)
		end
		 
		love.graphics.setColor(0,200,0)
		love.graphics.circle("fill", math.round(wmousex,grid.size),math.round(wmousey,grid.size),3)
		
	camera.unset()
	
	
	
	love.graphics.setColor(200,0,20)
	love.graphics.setLineWidth(camera.moveEdge*2)
	love.graphics.rectangle("line", 0,0,window.width,window.height)
	
	love.graphics.setColor(255,255,255)
	
	love.graphics.print("Round X: " .. math.round(wmousex,grid.size), 4,10)
	love.graphics.print("Round Y: " .. math.round(wmousey,grid.size), 4, 25)
	
	love.graphics.print("World X: " .. wmousex, 4, 45)
	love.graphics.print("World Y: " .. wmousey,4,60)
	
	love.graphics.print("Editor State: " .. editor.state,4,80)
	
end


function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'q' then
		if editor.state == 'adding' then
			editor.state = 'ready' 
			table.remove(level.blocks,1)
		elseif editor.state == 'connecting' then
			editor.state = 'readytoconnect'
		end
	elseif key == '-' then
		camera.xscale = camera.xscale*0.8
		camera.yscale = camera.yscale*0.8
	elseif key == '=' then
		camera.xscale = camera.xscale/0.8
		camera.yscale = camera.yscale/0.8
	elseif key == 'd' then	
		editor.state = 'delete'
	elseif key == 'a' then
		editor.state = 'ready'
	elseif key == 'g' then	
		grid.show = not grid.show
	elseif key == 'm' then
		editor.state = 'moving'
	elseif key == 'n' then	
		editor.state = 'nodes'
	elseif key == 'c' then
		editor.state = 'readytoconnect'
	end

end

function love.mousepressed(x,y,button)
	wx,wy = camera.getWorldPoint(x,y)
	if button == 1 then
		if editor.state == 'ready' then
			table.insert(level.blocks, 1, {})
			level.blocks[1].x,level.blocks[1].y = math.round(wx,grid.size),math.round(wy,grid.size)
			level.blocks[1].width,level.blocks[1].height = 0,0
			editor.state = 'adding'
		elseif editor.state == 'delete' then
			for i,v in ipairs(level.blocks) do
				if collision.pointRectangle(wx,wy,v.x,v.y,v.width,v.height) then
					table.remove(level.blocks,i)
				end
			end	
			for i,v in ipairs(level.nodes) do
				if collision.pointCircle(wx,wy,v.x,v.y,10) then
					table.remove(level.nodes,i)
				end
			end	
		elseif editor.state == 'moving' then
			for i,v in ipairs(level.blocks) do
				if collision.pointRectangle(wx,wy,v.x,v.y,v.width,v.height) then
					editor.selected = v
					editor.offsetx = math.round(wx,grid.size) - v.x
					editor.offsety = math.round(wy,grid.size) - v.y
					break
				end
			end	
		elseif editor.state == 'nodes' then
			table.insert(level.nodes, {})
			local n = #level.nodes
			level.nodes[n].x,level.nodes[n].y = math.round(wx,grid.size/2),math.round(wy,grid.size/2)
			level.nodes[n].connections = {}
		elseif editor.state == 'readytoconnect' then
			for i,v in ipairs(level.nodes) do
				if collision.pointRectangle(wx,wy,v.x-node.radius,v.y-node.radius,node.radius*2,node.radius*2) then
					editor.selected = v
					editor.state = 'connecting'
					break
				end
			end	
		end
		
	end

end

function love.mousereleased(x,y,button)
	if button == 1 then
		if editor.state == 'adding' then
			x,y = camera.getWorldPoint(x,y)
			level.blocks[1].width,level.blocks[1].height = math.round(x,grid.size) - level.blocks[1].x, math.round(y,grid.size) - level.blocks[1].y
			if level.blocks[1].width < 0 then
				level.blocks[1].width = -level.blocks[1].width
				level.blocks[1].x = level.blocks[1].x - level.blocks[1].width
			end
			if level.blocks[1].height < 0 then
				level.blocks[1].height = -level.blocks[1].height
				level.blocks[1].y = level.blocks[1].y - level.blocks[1].height
			end
			
			if level.blocks[1].height == 0 or level.blocks[1].width == 0 then
				table.remove(level.blocks,1)
			end	
			editor.state = 'ready'
		elseif editor.state == 'moving' then
			editor.selected = nil
		end
	end

end


function love.quit()
	grant.table.save(level.blocks,'level2.lua', "blocks = ")
	grant.table.save(level.nodes,'level2nodes.lua', "nodes = ")
end

-------Good Functions to Have---------------

function grid.draw()
	local left,top = camera.getWorldPoint(0,0)
	local right,bottom = camera.getWorldPoint(window.width,window.height)
	
	
end 


function math.round(x,n)
	local a =  math.floor(x/n)
	if x/n - a < 0.5 then
		return a * n
	end
	return n*a + n
end


