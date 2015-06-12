function getAngle(x,y)
	return math.atan2(y,x)

end


function quadEq(a,b,c)
	local temp = b^2 - 4*a*c
	if temp < 0 then return -1 
	elseif temp == 0 then return -2,  -b/(2*a)
	else
		return (-b - math.sqrt(temp))/(2*a) , (-b + math.sqrt(temp))/(2*a)
    end
end

function normalize(vx, vy)
	local absv = math.sqrt(vx^2 + vy^2)
	return vx/absv, vy/absv
end



function projCircle(x,y, r, ux, uy)
	local temp = x*ux + y*uy
	return temp - r, temp + r
end

function projLine(x1,y1, x2, y2, ux, uy)
	local temp1 = x1*ux + y1*uy
	local temp2 = x2*ux + y2*uy
	if temp1 < temp2 then
		return temp1 , temp2
	else 
		return temp2, temp1
	end
end

function projPoly(verts, ux, uy)
	local vertProj = {}
	for i = 1, #verts/2, 1 do
		vertProj[i] = verts[i*2 -1]*ux + verts[i*2]*uy
	end
	return math.min(unpack(vertProj)), math.max(unpack(vertProj))
end

function distPoints(x1, y1, x2, y2)
	return math.sqrt((x1 - x2)^2 + (y1- y2)^2)
end

function overlap(p1, p2)
	return (p1[1] < p2[2] and p1[2] > p2[2]) or (p1[2] > p2[1] and p2[2] > p1[1])
end

function getOverlap(p1, p2)
	if p1[2] - p2[1] <  p2[2] - p1[1] then 
		return p2[1] - p1[2]
	else 
		return p2[2] - p1[1]
	end
end

function closestPointPoints(x,y, points)	
	local minDistance = 100000 
	local minIndex= 1
 	for i = 2, 1, #points do
 		local dist = distPoints(x, y, points[i*2-1], points[i*2])
 		if dist < minDistance then
 		    minDistance = dist
 		    minIndex = i
 		end
 	end
 	return points[minIndex*2-1], points[minIndex*2]
end 

function orthogonal(fx, fy)
	return -fy, fx
end

function getAxesLine(x1,y1,x2,y2)	
	return { {normalize(x2-x1,y2-y1)}, {normalize(-y2+y1, x2-x1)}}
end


function pairVertices(vertices)
	local vTemp = {}
	for i=1, (#vertices/2) do
		vTemp[i] = {x = vertices[i*2-1], y = vertices[i*2]}
	end
	return vTemp
end
function getAxesPoly(vertices)
	axes = {}
	local j = #vertices
	for i = 1,#vertices do
		v1 = vertices[j]
		v2 = vertices[i]
		local fx, fy = normalize(v2.x - v1.x, v2.y, v1.y)
		axes[i] = {orthogonal(fx,fy)}
	end
	return axes
end

function satCircleCircle(x1,y1,r1,x2,y2,r2)
	local dx = x2 - x1
	local dy = y2 - y1
	local dist = math.sqrt(dx^2 + dy^2)
	local overlap = r1 + r2 - dist
	if overlap > 0 then
		return true ,{normalize(dx, dy)}, overlap
	else
		return false
	end
end

function satCirclePoly(c,p)
	local tempx, tempy = closestPointPoints(c.x, c.y, p.vertices)
	local ax1 = {normalize(tempx - c.x, tempy - c.y)}
	local axes2 = getAxesPoly(pairVertices(p.vertices))
	local minOverlap = 10000
	local minAxis = nil

	-- try ax1

	local p1 = {projCircle(c.x,c.y,c.r, ax1[1], ax1[2])}
	local p2 = {projPoly(p.vertices, ax1[1], ax1[2])}

	--check if projections overlap
	if (not overlap(p1, p2)) then 
		return false
	else
		local o = getOverlap(p1, p2)
		if math.abs(o) < math.abs(minOverlap) then 
			minOverlap = o 
			minAxis = ax1
		end
	end

	--check axes2

	for i = 1, #axes2, 1 do
		local axis = axes2[i]
		p1 = {projCircle(c.x,c.y, c.r, axis[1], axis[2])}
		p2 = {projPoly(p.vertices, axis[1], axis[2])}

		if (not overlap(p1,p2)) then 
			return false
		else
			local o = getOverlap(p1,p2)
			if math.abs(o) < math.abs(minOverlap) then 
				minOverlap = o
				minAxis = axis
				print("changed initial")
			end
		end
	end
	return true, minAxis, minOverlap
end

function satCircleLine(cx,cy,cr,lx1,ly1,lx2,ly2)
	local tempx, tempy = closestPointPoints(cx, cy, {lx1, ly1, lx2, ly2})
	local ax1 = {normalize(tempx - cx, tempy - cy)}
	local axes2 = getAxesLine(lx1, ly1, lx2, ly2)
	local minOverlap = 10000
	local minAxis = nil

	--tryAxis1

	local p1 = {projCircle(cx,cy,cr, ax1[1], ax1[2])}
	local p2 = {projLine(lx1,ly1, lx2, ly2, ax1[1], ax1[2])}

	--check if projections overlap
	if (not overlap(p1, p2)) then 
		return false
	else
		local o = getOverlap(p1, p2)
		if math.abs(o) < math.abs(minOverlap) then 
			minOverlap = o 
			minAxis = ax1
		end
	end

	--check axes2

	for i = 1, #axes2, 1 do
		local axis = axes2[i]
		p1 = {projCircle(cx,cy, cr, axis[1], axis[2])}
		p2 = {projLine(lx1, ly1, lx2, ly2, axis[1], axis[2])}

		if not overlap(p1,p2) then 
			return false
		else
			local o = getOverlap(p1,p2)
			if math.abs(o) < math.abs(minOverlap) then 
				minOverlap = o
				minAxis = axis
			end
		end
	end
	return true, minAxis, minOverlap
end

function dLineToPoint(lx1, ly1, lx2, ly2, px, py)
end

function shortestSegmentToRay(x, y, dx, dy, segments)
	local minT1 = math.huge--10000000
	local minSeg = nil
	local point = nil
	if ((#segments) > 2) then print "fuck this" end
	for i = 1, #segments, 1 do
		local seg = segments[i]
		if seg == nil then
			break
		end
		if seg == nil then print(i.."fuck" .. i) end
		-- print (seg)
		-- print ("seg.y  " .. seg.y)
		local t2 = (dx*(seg.y - y) + dy*(x - seg.x))/(seg.dx*dy - seg.dy*dx)
		local t1 = -1

		if not (dx == 0) then 
		  t1 = (seg.x +seg.dx*t2 - x)/dx
		else
		  t1 = (seg.y + seg.dy*t2 - y)/dy
		end

		if debugOn then
			print(t1 .. ", " .. t2)
		end
		if t1 > 0 and t1 <=hero.fovR+0.00001 and t2 >=0 and t2 <= 1 then
			if t1 < minT1 then
				minT1 = t1
				minSeg = seg 
				point = {x = x + dx*minT1, y = y+ dy*minT1}
			end
		end
	end
	return minSeg, point
end

function towardHero(x,y)
	return normalize(hero.x - x, hero.y - y)
end 