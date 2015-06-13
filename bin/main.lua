require "equations"
require "fov"
require "e1"
io.stdout:setvbuf("no")
debug = true

word = "Hellow"

--constants
speed = 50
SwordDelay = 15
SwordDuration = 10
SwordLength = 10
SwordTipLength = 4
SwordWidth = 2
spaceDown = false
FOV = 100
HeroRadius = 6
InvincTime = 0.3
KnockBackSpeed = 300


--debugging variables

hasIntersection = false


--initialize hero
hero = {vx = 0, vy = 0 , x = 50, y = 50, wantSwing = false, fx = 0., fy = 0., fovR = FOV, invinc = false, invincTimer = 0, knockedBack = false, knockBackTimer = 0, knockBackVX = 0, knockBackVY = 0, invincTime = InvincTime, attack = 10}

-- initialize sword
sword = {on = false, dur = 0, del = 0, vs ={0,0,0,0,0,0,0,0,0,0}, init = false }

-- initialize object list
objects = {}

walls = {}
activeWalls = {}
numActiveWalls = 0

enemies = {}
activeEnemies = {}

objectsToDraw = {}
objectsToDrawL = 0

--functions for enemys
enemyTypes = {e1 = e1}


-- function enemies.e1.act(x,y)
--   fx = hero.x - x
--   fy = hero.y - y
--   absv = math.sqrt(fx^2 + fy^2)
--   vx = speed * fx / absv
--   vy = speed * fy / absv
--   return vx,  vy
-- end


--creating a test enemy

--creating test walls

activeWalls = {}

numActiveWalls = 1



function isHeroHit()
  if hero.invinc then return false, nil
  else
    for i = 1, #activeEnemies do
      local e = activeEnemies[i]
      local hits, axis, overlap = e:hitHero()
      if hits then
        return true, axis
      end
    end
    return false, nil
  end
end

function love.load(arg)
	-- test of active walls
   activeWalls[1] = {x1 = 100, y1 = 100 , x2 = 200, y2 = 100}
   activeWalls[2] = {x1 = 200, y1 = 100, x2 = 300, y2 = 300}
   numActiveWalls = 2

   activeEnemies[1] = E1:new{x=300, y=300}
   activeEnemies[2] = E1:new{x=500, y=500}


   --test shader

   blendOut = love.graphics.newShader[[
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
      {
          number blackness = 100.0 - sqrt(abs(pow((300 - screen_coords.x),2) + pow((350-screen_coords.y), 2)));
          blackness = blackness/100.0;
          if (blackness < 0.0)
            blackness = 0.0;
          vec4 pixel = color;
          pixel.r = pixel.r*blackness;
          pixel.g = pixel.g*blackness;
          pixel.b = pixel.b*blackness;
          return pixel;
      }

   ]]




   debugOn = true

   -- print("Hello\n")
   -- print (closestPointPoints(0, 0, {100, 100, 200, 200}))
   -- ax1 = {normalize(100, 100)}
   -- print(ax1[2])
   -- p1 = {projCircle(hero.x,hero.y,HeroRadius, ax1[1], ax1[2])}
   -- print(p1[1])
   -- print(p1[2])
   -- p2 = {projLine(100,100,200,100, ax1[1], ax1[2])}
   -- print(p2[1])
   -- print(p2[2])
-- local segs = processWalls(activeWalls)
-- local dX, dY = normalize(1,1.0108848405518)
-- for i = 1 , #segs, 1 do
--   print (segs[i].x .. "," .. segs[i].y .. "," .. segs[i].dx .. "," .. segs[i].dy)
-- end
--    local s, p = shortestSegmentToRay(106.9577712242, 11.1, dX, dY, segs )
--    print(p.x .. ", " .. p.y)
    debugOn = false

print(math.atan(1))
print(math.atan(-1))



end

function love.update(dt)
  -- love.draw()

   --checking for keyboar input
   hero["vx"] = 0
   hero["vy"] = 0
   hero["wantSwing"] = false
   if love.keyboard.isDown("a") then
   	word = "a"
   	hero["vx"] = hero["vx"] -speed
   	hero["fx"] = hero["fx"] -1
   end
   if love.keyboard.isDown("d") then
     word = "d"
     hero["vx"] = hero["vx"] + speed
     hero["fx"] = hero["fx"] + 1
   end 
   if love.keyboard.isDown("w") then
       hero["vy"] = hero["vy"] -speed
       hero["fy"] = hero["fy"] -1
   end
   if love.keyboard.isDown("s") then
       hero["vy"] = hero["vy"] + speed
       hero["fy"] = hero["fy"] +1
   end

   if love.keyboard.isDown(" ") then
   	if  not spaceDown then
   		hero.wantSwing = true
   		spaceDown = true
   	else 
   		hero.wantSwing = false
   	end
   else
   	hero.wantSwing = false
   	spaceDown = false
   end

   

   --set facing direction

   if hero.vx > 0 then 
   	hero.fx = 1
   	if hero.vy == 0 then
   		hero.fy = 0
   	end
   end
   if hero.vx < 0 then
   	hero.fx = - 1
   	if hero.vy == 0 then
   		hero.fy = 0
   	end
   end
   if hero.vy > 0 then
       hero.fy = 1
       if hero.vx == 0 then
   		hero.fx = 0
   	end
   end
   if hero.vy < 0 then 
   	hero.fy = -1
   	 if hero.vx == 0 then
   		hero.fx = 0
   	end
   end

   --for test
   -- hero.fx = 1
   -- hero.fy = -1

   --normalize facing vector

   hero.fx , hero.fy = normalize(hero.fx, hero.fy)
   -- absv = math.sqrt(hero["fx"]^2 + hero["fy"]^2)

   -- hero["fx"] = hero["fx"] / absv
   -- hero["fy"] = hero["fy"] / absv



   --game logic

   --updating invinvibility

   if hero.invinc then
    if hero.invincTimer <= 0 then
      hero.invinc = false
    else
      hero.invincTimer = hero.invincTimer - dt
    end
   end

   --updating speed for knockback

   if hero.knockback then
    if hero.knockBackTimer <= 0 then
      hero.knockback = false
    else
      hero.knockBackTimer = hero.knockBackTimer - dt
      hero.vx = hero.knockBackVX
      hero.vy = hero.knockBackVY
    end
  end

  -- updating enemies statuses

  for i=1, #activeEnemies do 
    activeEnemies[i]:updateStatuses(dt)
  end

-- get active walls

--get active enemies




   --hero movement

   hero["x"] = hero["x"] + hero["vx"]*dt
   hero["y"] = hero["y"] + hero["vy"]*dt

   --correct for walls

   for i = 1, numActiveWalls, 1 do
    wall = activeWalls[i]
    intersects, dir, mag = satCircleLine(hero.x, hero.y, HeroRadius, wall.x1, wall.y1, wall.x2, wall.y2)
    if intersects then
      hasIntersection = true
      hero.x = hero.x + dir[1]*mag
      hero.y = hero.y + dir[2]*mag
    else
      hasIntersection = false
    end
   end

   --generate fov

   generateFOV(hero.x, hero.y, activeWalls)

   --TODO generate active enemy list


   --enemy movement

   for i = 1, #activeEnemies do
    local e = activeEnemies[i]
    e:getSpeed()
    e:move(dt)
   end



   --sword movement 
   if sword["on"] then
   	sword.init = true
   	word = "Sword on"
   	if sword["dur"] >= SwordDuration then
   		sword["on"] = false
   		sword["del"] = SwordDelay
   		sword["dur"] = 0
      for i = 1, #sword.vs do
        sword.vs[i] = -100
      end
   	else
   		sword["dur"] = sword["dur"] + 1
   		--calculate vertices of sword
   		--vector orthogonal to facing vector
   		ox = -hero["fy"]
   		oy = hero["fx"]

   		sword.vs[1] = SwordWidth*ox + hero.x
   		sword.vs[2] = SwordWidth*oy + hero.y
   		sword.vs[3] = SwordLength*hero.fx + sword.vs[1]
   		sword.vs[4] = SwordLength*hero.fy + sword.vs[2]
   		sword.vs[5] = SwordTipLength*hero.fx - ox*SwordWidth + sword.vs[3]
   		sword.vs[6] = SwordTipLength*hero.fy - oy*SwordWidth + sword.vs[4]
   		sword.vs[7] = -ox*2*SwordWidth + sword.vs[3]
   		sword.vs[8] = -oy*2*SwordWidth + sword.vs[4]
   		sword.vs[9] = -SwordWidth*ox + hero.x
   		sword.vs[10] = -SwordWidth*oy + hero.y
   		
   	end
   else
   	 --word = "checking"
     sword["del"] = sword["del"] - 1
     if hero.wantSwing and sword["del"] <= 0 then
     	word = "made it"
     	sword.on = true
     	sword.dur = 0
     	sword.init = false
     end 
   end

   --check if enemy is hit

   for i = 1, #activeEnemies do
    local e = activeEnemies[i]
    e:hitSword()
   end



   --check if hero is hit

   local isHit, axis = isHeroHit()
   if isHit then
    print("hit works")
    hero.knockback = true 
    hero.knockBackTimer = hero.invincTime
    hero.knockBackVX = axis[1]*KnockBackSpeed
    hero.knockBackVY = axis[2]*KnockBackSpeed
    hero.invinc = true
    hero.invincTimer = hero.invincTime
   end

   --check if enemies are dead

   local j = 1
   while j <= #activeEnemies do
    if activeEnemies[j].dead then
      table.remove(activeEnemies,j)
      j = j-1
    end
    j = j+1
  end

   -- debugging stuff
   word = ""
   word = word .. "hero stuff: \n x:" .. hero.x .. "\n y:" .. hero.y .. "\n sword:\n"
   word = word .. "fx:" .. hero.fx .. "\n" .. "fy:" .. hero.fy .. "\n"
   		for x,y in pairs(sword.vs) do
   			word = word .. y .. "\n"
   		end
  if hasIntersection then
    word = word .. "has intersection\n"
  end

  -- word = word .. "fov: \n"

  -- for i = 1, #fov, 1 do
  --   word = word .. i .. "ang:".. fov[i].angle .. ", " .. tostring(fov[i].blocked) .. "\n"
  --   word = word .. fov[i].x .. ", " .. fov[i].y .. "\n"
  -- end

  

  if hero.knockback then
    word = word .."being knocked back\n"
  end

  if hero.invinc then
    word = word .."hero is invincible\n"
  end


end

function love.draw(dt)
	love.graphics.print(word, 300, 0)


  -- drawing game window

  --centering window around hero

  love.graphics.push()
  love.graphics.translate(-hero.x, -hero.y)
  love.graphics.translate(300, 350)

  --adding shader
  love.graphics.setShader(blendOut)


  --drawing fov

  fovDraw(dt)

  --fovTestRays(dt)

  --drawing enemies(Stand in for final version)

  for i = 1, #activeEnemies do
    local e = activeEnemies[i]
    e:draw(e.x, e.y)
  end

	
	--drawing sword
	if sword.on and sword.init then
		love.graphics.setColor(255,0,0)
		love.graphics.polygon("fill", sword.vs)
	end

  

	--drawing hero
	love.graphics.setColor(51,204,51)
	love.graphics.circle("fill", hero["x"], hero["y"], HeroRadius, 200)
	

	-- --testing draw function will erase
	-- vertices = {233,284,233,287,231,287,231,284}
	-- love.graphics.setColor(0,100,0)
	-- love.graphics.polygon("fill", vertices)

	--drawing test walls 

	-- for i = 1 , numActiveWalls , 1 do
	-- 	love.graphics.setColor(0,0,255)
	-- 	wall = activeWalls[i]
	-- 	love.graphics.line(wall.x1, wall.y1, wall.x2, wall.y2)
	-- end

  love.graphics.pop()

  love.graphics.setShader()

  

 
end



function love.keypressed(key)
end