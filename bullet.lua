require 'map'
require 'utilities'

bulletSpeed = 300
bullets = {}
local bulletSize = 3

local drawBoundingBox = false

function BulletUpdate(dt)
  for i=#bullets, 1, -1 do
    bullets[i].x = bullets[i].x + (bullets[i].dx * dt)
    bullets[i].y = bullets[i].y + (bullets[i].dy * dt)

    bullets[i].bulletBoundingBox = {x = bullets[i].x - (bulletSize/2), y = bullets[i].y - (bulletSize/2), w = bulletSize, h = bulletSize}

    if CheckBulletPosition(bullets[i]) == true then
      table.remove(bullets, i)
    end
  end
end

function CheckBulletPosition(bullet)
  local removeBullet = false

  if bullet.x < 0 or bullet.x > (dungeonWidth * tileWidth) then
    removeBullet = true
  end

  if bullet.y < 0 or bullet.y > (dungeonHeight * tileHeight) then
    removeBullet = true
  end

  --loop through map and check for collision with bullet
  for row=1, dungeonHeight do
    for column=1, dungeonWidth do
     --dungeon[row][column] = { value = 0, boundingbox = { x= (column-1) * tileWidth, y= (row-1) * tileHeight, w=tileWidth, h=tileHeight } }
      if dungeon[row][column].value == 0 then
        if CheckCollisionBoundingBox(dungeon[row][column].boundingbox, bullet.bulletBoundingBox) == true then
          removeBullet = true
        end
      end
    end
  end

  return removeBullet
end

function CreateNewBullet(x, y)
  local startX = player.x + (player.width /2) --playerRealX
  local startY = player.y + (player.height /2)--playerRealY
  local mouseX = x
  local mouseY = y

  local angle = math.atan2((mouseY - startY), (mouseX - startX))

  local bulletDx = bulletSpeed * math.cos(angle)
  local bulletDy = bulletSpeed * math.sin(angle)

  bulletBoundingBox = {x = startX - (bulletSize/2), y = startY - (bulletSize/2), w = bulletSize, h = bulletSize}
  table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy, bulletBoundingBox})
end

function CheckBulletBounce()
  for i,v in ipairs(bullets) do

  end
end

function BulletDraw()
  love.graphics.print(#bullets, 10, 10)
  for i,v in ipairs(bullets) do
  	love.graphics.circle("fill", v.x, v.y, bulletSize)

    if drawBoundingBox == true then
      love.graphics.rectangle( "line", v.bulletBoundingBox.x, v.bulletBoundingBox.y, v.bulletBoundingBox.w, v.bulletBoundingBox.h)
    end
  end
end
