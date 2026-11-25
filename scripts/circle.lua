local obj = createCube()
local cam = createCamera()
local angle = 0
local var = 0

setActiveCamera(cam)
cam.freeLook = false

while true do
    var = var + .01     
    angle = angle + (2^var * .01)

    obj.position.x = 5 * math.cos(angle)
    obj.position.y = 5 * math.sin(angle)

    wait(.01)
end