require 'map'
require 'utilities'
require 'player'

local EnemyCount = 15
local Enemies = {}

function EnemyLoad()

  for enemy = 1, EnemyCount do
    local enemyImage = love.graphics.newImage('images/enemy8x8.png')
    local enemyWidth = enemyImage:getWidth()
    local enemyHeight = enemyImage:getHeight()
    --local enemyX, enemyY = 5,5
    local enemyGridX, enemyGridY = DetermingStartingSpot()
    local enemyRealX, enemyRealY = TranslateGridXYToXY(enemyGridX, enemyGridY, enemyWidth, enemyHeight, tileWidth, tileHeight)


    local enemyBoundingBox = {x = enemyRealX - (enemyWidth/2), y = enemyRealY - (enemyHeight/2), w = enemyWidth, h = enemyHeight}
    local pathMap = {}
    table.insert(Enemies, {x = enemyRealX, y = enemyRealY, w=enemyWidth, h=enemyHeight, gridX= enemyGridX, gridY = enemyGridY, image = enemyImage, enemyBoundingBox, enemyPath = pathMap, waitTime = 0.8})
  end
end

function DetermingStartingSpot()
  local goodStartingSpot = false
  local goodX, goodY = 0

  repeat
    local randX = love.math.random(1, dungeonWidth)
    local randY = love.math.random(1, dungeonHeight)

    --if dungeon[randY][randX] == 1 then
    if dungeon[randY][randX].value == 1 then
      goodX = randX
      goodY = randY

      goodStartingSpot = true
    end
  until goodStartingSpot == true

  return goodX, goodY
end

function EnemyUpdate(dt)
  for i=1, #Enemies do
  --for testing, let's do this for one or two enemies
  --for i=1, 1 do
    Enemies[i].waitTime = Enemies[i].waitTime - dt
    local route = {}

    local enemyPoints = { x=Enemies[i].gridX, y=Enemies[i].gridY }
    local targetPoints = { x=player.positionX, y = player.positionY }
    Enemies[i].pathMap, route = AStarPathfinding(dungeon, enemyPoints, targetPoints)
    --Enemies[i].pathMap = AStarPathfinding(dungeon, enemyPoints, targetPoints)

    if Enemies[i].waitTime <= 0 then
      --love.window.showMessageBox("Hit", "Movement hit", "error")
      Enemies[i].waitTime = 1

      --love.window.showMessageBox("Old Position", Enemies[i].x .. " " .. Enemies[i].y, "error")
      --love.window.showMessageBox("New Position", route[1].column .. " " .. route[1].row, "error")
      Enemies[i].gridX = route[1].column
      Enemies[i].gridY = route[1].row

      --set our xy
      Enemies[i].x, Enemies[i].y = TranslateGridXYToXY(Enemies[i].gridX, Enemies[i].gridY, Enemies[i].w, Enemies[i].h, tileWidth, tileHeight)

    end
  end
end

function EnemyDraw()
  for i,v in ipairs(Enemies) do
    love.graphics.draw(v.image, v.x, v.y)
    --if drawBoundingBox == true then
      --love.graphics.rectangle( "line", v.bulletBoundingBox.x, v.bulletBoundingBox.y, v.bulletBoundingBox.w, v.bulletBoundingBox.h)
    --end
    --DrawPathMap(v.pathMap)
  end
  --for i=1, 1 do
  for i=1, #Enemies do
    --DrawPathMap(Enemies[i].pathMap)
    love.graphics.print(Enemies[i].waitTime, 50, 50)

  end
end
