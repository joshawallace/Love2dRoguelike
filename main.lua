require 'map'  --need our map functions
require 'player' --player related functions
require 'bullet' --bullet related functions
require 'enemy'

local debugInfo = "Nothing Here"

function love.load()
   --love.keyboard.setKeyRepeat(true)
   --set our bg color to white (255,255,255)  so we can see shit
   love.graphics.setBackgroundColor(255, 255, 255)

   --set our window size to the size of our map
   love.window.setMode(dungeonWidth * tileWidth, dungeonHeight * tileHeight)

   --load and initialize our map
   MapLoad()
   PlayerLoad()
   EnemyLoad()

end  --end load function

function love.update(dt)
  --PlayerUpdate(dt)
  BulletUpdate(dt)
  EnemyUpdate(dt)
end

function love.keyreleased(key)
   PlayerKeyReleased(key)
end

function love.mousereleased(x, y, button)
  if button == 1 then
    CreateNewBullet(x, y)
	end
end

--this is where we draw shit
function love.draw()
  MapDraw()

  EnemyDraw()
  PlayerDraw()
  BulletDraw()

  --love.graphics.print(debugInfo, 10, 25)
end
