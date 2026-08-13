collision = {}

function collision.rectangles(left1,top1,width1,height1, left2,top2,width2,height2)
	return (left1 + width1 > left2 and left1 < left2 + width2 and top1 < top2 + height2 and top1 + height1 > top2)
end
--(v.x+(v.width/2)) > (player.x - (player.width/2)) and (v.x-(v.width/2)) < (player.x + (player.width/2)) and (v.y-(v.height/2)) < (player.y+(player.height/2)) and (v.y+(v.height/2)) > (player.y - (player.height/2))


function collision.circles(centerx1,centery1,radius1, centerx2,centery2,radius2)
	return (  ( ((centerx1-centerx2)^2) + ((centery1-centery2)^2) )^0.5 < (radius1 + radius2) )
end

function collision.rectangleCircle(left1,top1,width1,height1, centerx2,centery2,radius2) 
--Just an approximation
	return collision.rectangles(left1,top1,width1,height1, centerx2-radius2,centery2-radius2, radius2*2, radius2*2)
end

function collision.pointRectangle(x,y,  left,top,width,height)
	return (x < left+width and x > left and y > top and y < top + height)
end

function collision.pointCircle(x,y, centerx,centery,radius)
	return (  ( ((x-centerx)^2) + ((y-centery)^2) ) < radius )
end

function collision.getBoundingBox(array)
	local left = 99999999999
	local right = -9999999999
	local top = left
	local bottom = right
	local odd = true
	for i,v in pairs(array) do
		if odd then
			if v < left then
				left = v
			elseif v > right then
				right = v
			end
		else
			if v < top then
				top = v
			elseif v > bottom then
				bottom = v
			end
		end
		odd = not odd
	end
	
	return left, top, right-left, bottom-top
end