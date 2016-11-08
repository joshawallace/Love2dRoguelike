require 'utilities'

tileWidth = 16       --hardcode our tile dimensons
tileHeight = 16      --don't really need to do this, but it makes the code more readable, though less flexible

dungeonWidth = 70     --the dungeon width in tiles
dungeonHeight = 40    --the dungeon height in tiles

local roomsToCreate = 18    --how many dungeon rooms to create
local maxRoomWidth = 8    --max room width
local maxRoomHeight = 8   --max room height
local minRoomWidth = 3    --min room width
local minRoomHeight = 2   --min room height

local drawBoundingBoxMap = true

---------------------------------
--  0 = unvisited / blank tile
--  1 = dungeon floor
------------------------------------
--Initialze the table (array) that will hold our dungeon
dungeon = { }
--A separate table to hold our rooms at a high level. Currently using this for hall duration
--{roomX, roomY, roomWidth, roomHeight}
dungeonRooms = {}

function MapLoad()
  --load up our images. images are 16x16
  floor = love.graphics.newImage('images/floor16x16.png')
  floor2 = love.graphics.newImage('images/floor16x162.png')
  blank = love.graphics.newImage('images/blank16x16.png')
  hall = love.graphics.newImage('images/hall16x16.png')

  --initialize our dungeon
  initDungeon()

  --create out dungeon rooms
  createDungeonRooms()

  --create some hallways
  createHalls()
end

function initDungeon()
  --initialize our rows with blank additional arrays
  --this is lua's way of making a multi-dimensional array
  --basically, make a number of rows equal to the height of our dungeon
  for x=1, dungeonHeight do
    dungeon[x] = {}
  end

  for x=1, roomsToCreate do
    dungeonRooms[x] = {}
  end

  --Now we need to go through and set a 0 for every field in our table to initialie it as
  --blank dungeon space. Remember, you can't use shit without initializing it first.
  --loop through all of our columns, and all of our rows, and set the value to 0
  for row=1, dungeonHeight do
    for column=1, dungeonWidth do
     --dungeon[row][column] = { value = 0, boundingbox = { x= (column-1) * tileWidth, y= (row-1) * tileHeight, w=tileWidth, h=tileHeight } }
     dungeon[row][column] = { value = 0, walkable = false, boundingbox = GetTileBoundingBox(row, column)}
    end
  end
end

function GetTileBoundingBox(row, column)
  local x, y = 0, 0

  bbY = (row-1) * tileHeight
  bbX = (column-1) * tileWidth

  local width = tileWidth
  local height = tileHeight

  local TileBoundingBox = { x = bbX, y = bbY, w = width, h = height }
  return TileBoundingBox
end

--this function create the random rooms
function createDungeonRooms()
  --variable declaration. These are just placeholder values for now
  local roomWidth = 1
  local roomHeight = 1
  local roomX = 1
  local roomY = 1

  --for loop to create our rooms
  for roomCount=1, roomsToCreate do
    --holds whether or not our current room is invalid. By default, make it invalid
    local badRoom = true

    repeat
      --pick some random x,y coordinates on the map and also randomly determine the size of our room
      --rooms of the same size are boring
      roomWidth = love.math.random(minRoomWidth, maxRoomWidth)
      roomHeight = love.math.random(minRoomHeight, maxRoomHeight)
      roomX = love.math.random(1, dungeonWidth -  roomWidth)
      roomY = love.math.random(1, dungeonHeight - roomHeight)

      --run our check function to determine if the room is good or not
      badRoom = CheckRoomPlacement(roomX, roomY, roomWidth, roomHeight)
    --repeat until the room is good
    until badRoom == false

    --add it to a separate array, this will come in handy for generating halls (hopefully)
    dungeonRooms[roomCount] = {roomX, roomY, roomWidth, roomHeight}

    --run another for loops to set the appropriate tiles to floor tiles
    for xPos=roomX, roomX + roomWidth do
      for yPos=roomY, roomY + roomHeight do
        --dungeon[yPos][xPos] = 1
        dungeon[yPos][xPos] = { value = 1, walkable = true, boundingbox = GetTileBoundingBox(yPos, xPos) }
      end -- end for
    end -- end for

  end -- end for loop
end

--this function is responsible for checking the proposed coordinates and size for a room and determining if they
--are good. If the room overlaps with another room, it is considered bad
function CheckRoomPlacement(x, y, width, height)
  local badPlacement = false

  --if we try to place a 1 where there is already a 1, then we are overlapping our rooms
  for xPos=x, x + width do
    for yPos=y, y + height do
      --if dungeon[yPos][xPos] == 1 then
      if dungeon[yPos][xPos].value == 1 then
        --love.window.showMessageBox("True", "Bad room placement found", "error")
        return true
      end
    end
  end

  return false
end

--this function will create some hallways
function createHalls()
  --for loop to make our halls. Set it to the size of our table -1. This will make sure that all rooms have at least
  --one connection to another room. Halls and rooms can possibly overlap
  for roomCount=1, #dungeonRooms -1 do
    --set our current room
    local CurrentRoom = dungeonRooms[roomCount]
    --get the next room in our table
    local NextRoom = dungeonRooms[roomCount + 1]

    --get a random x,y coordinate from each of the two rooms
    local aX = CurrentRoom[1] + love.math.random(0, CurrentRoom[3])
    local aY = CurrentRoom[2] + love.math.random(0, CurrentRoom[4])
    local bX = NextRoom[1] + love.math.random(0, NextRoom[3])
    local bY = NextRoom[2] + love.math.random(0, NextRoom[4])

    --fancy map
    for hallX = math.min(aX, bX), (math.min(aX, bX) + math.abs(aX-bX)) do
      --dungeon[bY][hallX] = 1
      dungeon[bY][hallX] = { value = 1, walkable = true, boundingbox = GetTileBoundingBox(bY, hallX) }
    end

    for hallY = math.min(aY, bY), (math.min(aY, bY) + math.abs(aY-bY)) do
      --dungeon[hallY][aX] = 1
      dungeon[hallY][aX] = { value = 1, walkable = true, boundingbox = GetTileBoundingBox(hallY, aX) }
    end

  end
end

--draw our map
function MapDraw()
  --loop through our dungeon array and draw tiles to the screen based on the value in each "cell"
  for row=1, dungeonHeight do
    for column=1, dungeonWidth do
      --if dungeon[row][column] == 0 then
      if dungeon[row][column].value == 0 then
        love.graphics.draw(blank, (column-1) *tileWidth, (row-1) * tileHeight)

        if drawBoundingBoxMap == true then
          --love.graphics.rectangle("line", dungeon[row][column].boundingbox.x, dungeon[row][column].boundingbox.y, dungeon[row][column].boundingbox.w, dungeon[row][column].boundingbox.h)
          --love.graphics.rectangle("line", (column-1) *tileWidth, (row-1) * tileHeight, tileWidth, tileHeight)
        end
      --elseif dungeon[row][column] == 1 then
      elseif dungeon[row][column].value == 1 then
        love.graphics.draw(floor, (column-1) * tileWidth, (row-1) * tileHeight)

        if drawBoundingBoxMap == true then
          love.graphics.rectangle("line", dungeon[row][column].boundingbox.x, dungeon[row][column].boundingbox.y, dungeon[row][column].boundingbox.w, dungeon[row][column].boundingbox.h)
        end
      end
    end
  end
end
