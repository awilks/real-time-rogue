require "game"
require "equations"
require "fov"
require "e1"
require "enemyEquations"
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
  gamestate = game
  game.load()
	
end

function love.update(dt)
  -- love.draw()

  gamestate.update(dt)
end

function love.draw(dt)

  gamestate.draw(dt)
end



function love.keypressed(key)
end