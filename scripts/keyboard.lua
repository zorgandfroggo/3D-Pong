local cube = createCube()

while true do
    local keys = captureKeyboard()
    if (keys[87]) then
        cube.position.x = cube.position.x + 1
    end
    wait(.01)
end