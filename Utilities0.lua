
local pathImage = love.graphics.newImage('images/p16x16.png')
local mapWidth = 0

-- Collision detection function.
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollisionXYWH(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

--This is exactly like the collision detection function above, except we pass in two
--bounding boxes rather than indiviual points
function CheckCollisionBoundingBox(BoundingBox1, BoundingBox2)
  return BoundingBox1.x < BoundingBox2.x + BoundingBox2.w and
         BoundingBox2.x < BoundingBox1.x + BoundingBox1.w and
         BoundingBox1.y < BoundingBox2.y +BoundingBox2.h and
         BoundingBox2.y < BoundingBox1.y + BoundingBox1.h
end


--this function is responsible for taking a tile placement position and converting it into
--x, y coordinates
function TranslateGridXYToXY(gridPositionX, gridPositionY, objectWidth, objectHeight, baseTileWidth, baseTileHeight)
  local realX, realY = 0,0

  --tables are essentially an array that starts 1, rather than 0. So we need to subtract 1 from our grid position.
  --otherwise we end up with a tilewidth/tileheight spaced gap around the edges
  realX = ((gridPositionX-1) * baseTileWidth) + (objectWidth/2)
  realY = ((gridPositionY-1) * baseTileHeight) + (objectHeight/2)

  return realX, realY
end


function AStarPathfinding(originalMap, pointA, pointB)
  local closedList = {}
  local openList = {}
  --local nextNode = {}

  local nextNode = { row = pointA.y, column= pointA.x}
  local keepGoing = true
  local times = 20

  repeat
    table.insert(closedList, { row=nextNode.row, column=nextNode.column, f=0, g=0, h=0, parentRow=pointA.y, parentColumn=pointA.x})
    closedList, openList, nextNode = AddSurroundingToOpenList(nextNode, pointB, originalMap, closedList, openList)

    if nextNode.row == pointB.y and nextNode.column == pointB.x then
      love.window.showMessageBox("Point A = Point B", "Boing", "error")
      keepGoing = false
    end

    times = times -1
  until times == 0 or keepGoing == false
  return openList
end

function IsItemOnClosedList(row, column, closedList)
  for i=1, #closedList do
    if closedList[i].row == row and closedList[i].column == column then
      return true
    else
      return false
    end
  end
end

function IsItemOnOpenList(row, column, openList)
  for i=1, #openList do
    if openList[i].row == row and openList[i].column == column then
      return true
    else
      return false
    end
  end
end

function AddSurroundingToOpenList(startingSquare, target, theMap, theClosedList, theOpenList)
  local lowestF = 100000
  local lowestFNode = {}

  for column =-1, 1 do
    for row = -1, 1 do
      local newX = startingSquare.column + column
      local newY = startingSquare.row + row

      if theMap[newY][newX].walkable == true and IsItemOnClosedList(newY, newX, theClosedList) ==false then

        local node = { row=newY, column=newX, f=0, g=0, h=0, parentRow=startingSquare.y, parentColumn=startingSquare.x}
        node.g = CalculateG(row, column)
        node.h = CalculateH(node, target)
        node.f = node.g + node.h
        table.insert(theOpenList, node)

        if node.f < lowestF then
          lowestF = node.f
          lowestFNode = node
        end
      end

    end
  end

  --remove the starting square from the open list and add it to the closed list
  for i=#theOpenList, 1, -1 do
    if theOpenList[i].row == startingSquare.y and theOpenList[i].column == startingSquare.x then
      table.insert(theClosedList, theOpenList[i])
      table.remove(theOpenList, i)
    end
  end


  table.insert(theClosedList, lowestFNode)
  for i=#theOpenList, 1, -1 do
    if theOpenList[i].row == lowestFNode.row and theOpenList[i].column == lowestFNode.column then
      table.remove(theOpenList, i)
    end
  end
  --table.remove(theOpenList, removeSpot)

  return theClosedList, theOpenList, lowestFNode
end

function CalculateG(row, column)
  local gScore = 0

  if column == 0 or row == 0 then
    gScore = 10
  else
    gScore = 14
  end

  return gScore
end

function CalculateH(currentNode, targetPoint)
  local runningH = 0

  runningH = runningH + math.abs(currentNode.row - targetPoint.y)
  runningH = runningH + math.abs(currentNode.column - targetPoint.x)

  return runningH
end

function DrawPathMap(map)
  --for row=1, #map do
  --local fullRow = map[row]
    --for column=1, #fullRow do
      --if map[row][column].pfValue == "open" then
        --love.graphics.print(map[row][column].g, ((column-1) * 16) + 2, ((row-1) * 16) + 2 )
      --end
    --end
  --end
  for i =1, #map do
    love.graphics.print(map[i].f, ((map[i].column -1 ) * 16) + 2, ((map[i].row -1 ) * 16) + 2 )
  end
end
