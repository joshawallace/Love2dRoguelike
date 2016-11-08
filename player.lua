require 'map'

player = {x = 0, y = 0, width = 0, height = 0, positionX = 0, positionY = 0}
playerBoundingBox = { x =0, y =0, w =0, h =0}

function PlayerLoad()
  --load our player
  playerImage = love.graphics.newImage('images/player8x8.png')
  player.width = playerImage:getWidth()
  player.height = playerImage:getHeight()

  playerBoundingBox.w = player.width
  playerBoundingBox.h = player.height

  PlayerInit();
end

function PlayerInit()
  goodStartingSpot = false

  repeat
    local randX = love.math.random(1, dungeonWidth)
    local randY = love.math.random(1, dungeonHeight)

    --if dungeon[randY][randX] == 1 then
    --if dungeon[randY][randX].value == 1 then
    --if dungeon[randY][randX].walkable == true then
    if CanPlayerMoveThere(randX, randY) == true then
      --playerPositionX = (randX * tileWidth) - 8
      --playerPositionY = (randY * tileHeight) - 8
      player.positionX = randX
      player.positionY = randY

      goodStartingSpot = true
    end
  until goodStartingSpot == true

  --player.x, player.y = TranlatePlayerXY(player.positionX, player.positionY)
  player.x, player.y = TranslateGridXYToXY(player.positionX, player.positionY, player.width, player.height, tileWidth, tileHeight)
end

function PlayerKeyReleased(key)
  local startingX = player.positionX
  local startingY = player.positionY
  local newX = player.positionX
  local newY = player.positionY

  if key == 's' then
    newY = player.positionY + 1
  elseif key == 'w' then
    newY = player.positionY - 1
  elseif key == 'a' then
    newX = player.positionX - 1
  elseif key == 'd' then
    newX = player.positionX + 1
  end

  if CanPlayerMoveThere(newX, newY) == false then
    newX = startingX
    newY = startingY
  end

  player.positionX = newX
  player.positionY = newY

  --player.x, player.y = TranlatePlayerXY(newX, newY)
  player.x, player.y = TranslateGridXYToXY(player.positionX, player.positionY, player.width, player.height, tileWidth, tileHeight)
end

function CanPlayerMoveThere(playerX, playerY)

  if (playerX > dungeonWidth) or (playerX < 1) then
    return false
  end

  if (playerY > dungeonHeight) or (playerY < 1) then
    return false
  end

  --if dungeon[playerY][playerX] == 1 then
  if dungeon[playerY][playerX].walkable == true then
      return true
  end

  return false
end

--[[function TranlatePlayerXY(gridPositionX, gridPositionY)
  local realX, realY = 0,0

  realX = ((gridPositionX-1) *tileWidth) + (player.width/2)
  realY = ((gridPositionY-1) * tileHeight) + (player.height/2)

  return realX, realY
end]]--

function PlayerDraw()
  --love.graphics.draw(player, playerPositionX, playerPositionY)
  --love.graphics.draw(player, ((playerPositionX-1) *tileWidth) + (playerWidth/2), ((playerPositionY-1) * tileHeight) + (playerHeight/2))
  love.graphics.draw(playerImage, ((player.positionX-1) *tileWidth) + player.width/2, ((player.positionY-1) * tileHeight) + player.height/2)

  --love.graphics.print(playerRealX, 50, 50)
  --love.graphics.print(playerRealY, 50, 75)
end
