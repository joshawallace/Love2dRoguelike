
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

--this is our pathfinding algorithm. We pass in the original dungeon map, the grid positions of the objectWidth
--we want to find a path for, and the grid positions of where we are finding a path to. In this instance, point a
--is the enemy position and point b is the player
function AStarPathfinding(originalMap, pointA, pointB)
  --extract the xy positions from the tables passed in
  local column1 = pointA.x
  local column2 = pointB.x

  local row1 = pointA.y
  local row2 = pointB.y

  local targetReached = false
  local route = {}

  --initialize our map
  local pathMap = InitPathFindingMap(originalMap)
  local maxAttempts = 40

  --[[Begin at the starting point A and add it to an “open list” of squares to be considered. The open list is kind
  of like a shopping list. Right now there is just one item on the list, but we will have more later.
  It contains squares that might fall along the path you want to take, but maybe not.
  Basically, this is a list of squares that need to be checked out.   ]]
  pathMap[row1][column1].pfValue = "open"
  local lowestFPoint = { row = row1, column = column1 }

  --if (column1 == column2) and (row1 == row2) then
    --stuff
  --else
    repeat


      --[[Look at all the reachable or walkable squares adjacent to the starting point, ignoring squares
      with walls, water, or other illegal terrain. Add them to the open list, too.
      For each of these squares, save point A as its “parent square”.
      This parent square stuff is important when we want to trace our path. It will be explained more later.  ]]--

      --love.window.showMessageBox("Lowest F Main Initial Value", lowestFPoint.row .. " " .. lowestFPoint.column, "error")
      pathMap, lowestFPoint = MarkSurroundingOpen(pathMap, lowestFPoint.row, lowestFPoint.column, row2, column2)

      if pathMap[lowestFPoint.row][lowestFPoint.column].walkable == false then
        --love.window.showMessageBox("Unwalkable path found", lowestFPoint.row .. " " .. lowestFPoint.column, "error")
      end

      --[[Drop the starting square A from your open list, and add it to a “closed list” of squares
      that you don’t need to look at again for now. ]]--
      --pathMap[row1][column1].pfValue="closed"
      --love.window.showMessageBox("Lowest F Main", lowestFPoint.row .. " " .. lowestFPoint.column, "error")
      pathMap[lowestFPoint.row][lowestFPoint.column].pfValue="closed"
      table.insert(route, lowestFPoint)

      --row1 = lowestFPoint.row
      --column1 = lowestFPoint.column

      if (lowestFPoint.row == row2) and (lowestFPoint.column == column2) then
        targetReached = true
      end

      maxAttempts = maxAttempts -1
    until targetReached == true or maxAttempts == 0
  --end

  return pathMap, route
end

--initialize our map, give all the values as closed, and assign a null parent node
function InitPathFindingMap(originalMap)

  local modifiedMap = {}

  --initialize our new array
  for x=1, #originalMap do
    modifiedMap[x] = {}
  end

  for row=1, #originalMap do
    local fullRow = originalMap[row]
    mapWidth = #fullRow
    for column=1, #fullRow do
      modifiedMap[row][column] = { value = originalMap[row][column].value, walkable = originalMap[row][column].walkable, pfValue="", parentRow=0, parentColumn=0, f = 0, g = 0, h = 0}
    end
  end

  return modifiedMap
end

function MarkSurroundingOpen(map, row, column, row2, column2)
  local lowestF = 10000
  local lowestFPoint = {row = row, column = column}

  for colModifier = -1, 1 do
    for rowModifier = -1, 1 do
      if (rowModifier == 0) and (colModifier == 0) then
        local GValueToAdd = 0
      --elseif map[row + rowModifier][column + colModifier].walkable == false then
        --local GValueToAdd = 0
      else--if map[row + rowModifier][column + colModifier].pfValue == "open" then --if (row + rowModifier >0) and (row + rowModifier <= mapWidth)
          --and (column + colModifier >0) and (column + colModifier < #map)  then
        local GValueToAdd = 0
        local HValue = 0

        local newColumn = column + colModifier
        local newRow = row + rowModifier
        --local lowestFPoint = {}

        map = MarkYXAsOpen(map, newRow, newColumn, row, column)

        --A horizontal or vertical move gets a score of 10
        --A diagonal move gets a score of 14
        --[[ the way to figure out the G cost of that square is to take the G cost of its parent,
        and then add 10 or 14 depending on whether it is diagonal or orthogonal]]
        --if map[row + rowModifier][column + colModifier].pfValue == "open" then
          if (rowModifier == 0) or (colModifier == 0) then
            GValueToAdd = 10
          --elseif (rowModifier == 0) and (colModifier == 0) then
            --GValueToAdd = 0
          else
            GValueToAdd = 14
          end

          --local parentG = map[row][column].g
          local parentG = map[row][column].g

          map[newRow][newColumn].g = parentG + GValueToAdd
          map[newRow][newColumn].h = CalculateHValue(newColumn, column2, newRow, row2)
          map[newRow][newColumn].f = map[newRow][newColumn].g + map[newRow][newColumn].h

          if map[newRow][newColumn].walkable == true and map[newRow][newColumn].pfValue == "open" then
            if map[newRow][newColumn].f <= lowestF then
              lowestF = map[newRow][newColumn].f
              lowestFPoint = { row = newRow, column = newColumn }
              --love.window.showMessageBox("Lowest F Opener", lowestFPoint.row .. " " .. lowestFPoint.column, "error")
            end
          end


          --end
        --end
      end -- end if if else

    end -- end for
  end  -- end for

  map[lowestFPoint.row][lowestFPoint.column].pfValue = "closed"
  --love.window.showMessageBox("Returning F Point", lowestFPoint.row .. " " .. lowestFPoint.column, "error")
  return map, lowestFPoint
end --end function

function CalculateHValue(aX, bX, aY, bY)
  local hValue = 0

  --for xMovement = math.min(aX, bX), (math.min(aX, bX) + math.abs(aX-bX) - 1) do
  --for xMovement = math.abs(aX - bX) do
    --hValue = hValue + 1
    hValue = hValue + math.abs(aX - bX)
  --end

  --for yMovement = math.min(aY, bY), (math.min(aY, bY) + math.abs(aY-bY) - 1) do
  --for yMovement = math.abs(aY - bY) do
    hValue = hValue + math.abs(aY - bY)
  --end

  hValue = hValue

  return hValue
end

function MarkYXAsOpen(map, row, column, prow, pcolumn )
  --love.window.showMessageBox("Mark as open hit", row .. column, "error")

  if map[row][column].walkable ==true then --and map[row][column].pfValue~="closed" then
    map[row][column].pfValue="open"
    map[row][column].parentColumn = pcolumn
    map[row][column].parentRow = prow
    --love.window.showMessageBox("MarkasXY", "Walkable", "error")
  else
    --map[row][column].pfValue="closed"
    --love.window.showMessageBox("MarkasXY", "unwalkable", "error")
  end

  return map
end

--F = G + H
--[[G = the movement cost to move from the starting point A to a given square on the grid,
    following the path generated to get there. ]]--

  --[[H = the estimated movement cost to move from that given square on the grid to the final destination, point B.
  This is often referred to as the heuristic, which can be a bit confusing.
  The reason why it is called that is because it is a guess.
  We really don’t know the actual distance until we find the path,
    because all sorts of things can be in the way (walls, water, etc.).
  ]]


function DrawPathMap(map)
  for row=1, #map do
  local fullRow = map[row]
    for column=1, #fullRow do
      if map[row][column].pfValue == "open" then
        love.graphics.print(map[row][column].f, ((column-1) * 16) + 2, ((row-1) * 16) + 2 )
      end
    end
  end
end
