fov = {}

function processWalls(activeWalls)
	local wallSegs = {}
	for i = 1, #activeWalls, 1 do
		--might have to change if I add more wall types
		local wall = activeWalls[i]
		wallSegs[i] = {x = wall.x1,y = wall.y1, dx = wall.x2 - wall.x1, dy = wall.y2 - wall.y1}
	end
	return wallSegs
end

function getFovRays(x,y, activeWalls, perIntersections)
	local rays = {}
	local j=7
	rays[1] = -0.00001
	rays[2] = 0
	rays[3] = 0.00001
	rays[4] = math.pi - 0.00001
	rays[5] = math.pi
	rays[6] = math.pi + 0.00001
	for i=1, #activeWalls, 1 do
		local wall = activeWalls[i]
		--for staright line walls
		-- local ang1 =math.atan((wall.y1 - y)/ (wall.x1 - x))
		-- if wall.x1 - x < 0 then
		--  	ang1 = ang1 - math.pi 
		--  end
		local ang1 = getAngle(wall.x1 - x, wall.y1 - y)
		rays[j] = ang1 - 0.00001
		rays[j+1] = ang1
		rays[j+2] = ang1 + 0.00001
		-- local ang2 = math.atan((wall.y2 - y)/ (wall.x2 - x))
		-- if wall.x2 -x < 0 then
		-- 	ang2 =  ang2 - math.pi
		-- end
		local ang2 = getAngle(wall.x2 - x, wall.y2 - y)
		rays[j+3] = ang2 - 0.00001
		rays[j+4] = ang2
		rays[j+5]= ang2 +0.00001
		j = j+6
	end
	for i = 1, #perIntersections do
		ints = perIntersections[i]
		-- local ang =math.atan((ints.y - y)/ (ints.x - x))
		-- if ints.x - x < 0 then
		--  	ang = ang - math.pi 
		-- end 
		local ang = getAngle(ints.x - x, ints.y - y)
		rays[j] = ang - 0.00001
		rays[j+1] = ang
		rays[j+2] = ang + 0.00001
		j = j+3
	end

	--get intersections with perimeter




	return rays
end

function getPerIntersections(x,y,wallSegs)
	local perIntersections = {}
	local j = 1
	for i = 1, #wallSegs do
		local seg = wallSegs[i]
		-- quick fix for nil seg problem
		if seg == nil then
			break
		end
		local t1, t2 = quadEq(seg.dx^2 +seg.dy^2, 2*(seg.dy*(seg.y - y) + seg.dx*(seg.x - x)), (seg.y - y)^2 + (seg.x - x)^2 - hero.fovR^2)
		if t1 == -1 then
		elseif t1 == -2 then 
			perIntersections[j] = {x = seg.x + t2*dx, y = seg.y + t2*dy}
			j = j+1
		else
			perIntersections[j] = {x = seg.x + t1*seg.dx, y = seg.y + t1*seg.dy}
			perIntersections[j+1] = {x = seg.x + t2*seg.dx, y = seg.y + t2*seg.dy} 
			j = j+2
		end
	end
	return perIntersections
end

function generateFOV(x, y, activeWalls)
	fov = {}
	local wallSegs = processWalls(activeWalls)
	local perIntersections = getPerIntersections(x,y, wallSegs)
	local rays = getFovRays(x, y, activeWalls, perIntersections)
	table.sort(rays)
	local i =1
	for i = 1, #rays, 1 do
		local ray = rays[i]
		local sgn = 1
		if ray > math.pi/2 or ray < -math.pi/2 then 
			sgn = -1
		end
		local dx, dy = normalize(sgn*1, sgn*math.tan(ray))
		local seg, p = shortestSegmentToRay(x, y, dx, dy,wallSegs)
		if p == nil then
			fov[i] = {x= x + dx*hero.fovR, y= y+ dy*hero.fovR, blocked=false, angle = ray}
		else 
			fov[i] = {x = p.x, y = p.y, blocked = true, angle = ray}
		end
		while rays[i+1] == ray and i <= #rays do
			i = i + 1
		end
	end
end

function fovDraw(dt)
	love.graphics.setColor(255,204,0)
	if fov[1].blocked then
			love.graphics.polygon("fill", fov[#fov].x, fov[#fov].y, fov[1].x, fov[1].y, hero.x, hero.y)
		else 
			love.graphics.arc("fill", hero.x, hero.y, hero.fovR, fov[#fov].angle-math.pi*2, fov[1].angle, 1000)
		end
	for i= 1, #fov-1, 1 do
		if fov[i+1].blocked then
			love.graphics.polygon("fill", fov[i].x, fov[i].y, fov[i+1].x, fov[i+1].y, hero.x, hero.y)
		else 
			love.graphics.arc("fill", hero.x, hero.y, hero.fovR, fov[i].angle, fov[i+1].angle, 1000)
		end
	end
end

function fovTestRays(dt)
	love.graphics.setColor(255,204,155)
	for i = 1, #fov, 1 do
		dir = fov[i]
		love.graphics.line(hero.x, hero.y, dir.x, dir.y)
	end

end

