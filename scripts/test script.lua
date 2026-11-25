local obj1 = createCube()
local loop = true
local moveFront = true
local moveRight = false

while (loop) do
    if obj1.position.x >= 5 then
        moveFront = false
    elseif obj1.position.x <= -5 then
        moveFront = true
    end

    if obj1.position.y >= 5 then
        moveRight = false
    elseif obj1.position.y <= -5 then
        moveRight = true
    end

    if moveFront then
        obj1.position.x = obj1.position.x + .1
    elseif not moveFront then
        obj1.position.x = obj1.position.x - .1
    end

    if moveRight then
        obj1.position.y = obj1.position.y + .1
    elseif not moveRight then
        obj1.position.y = obj1.position.y - .1
    end
    wait(.01)
end