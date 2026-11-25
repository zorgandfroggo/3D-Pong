local cam = createCamera()
local obj = createCube()
local sphere = createSphere()

sphere.position.y = -5
obj.position.y = 5

setActiveCamera(cam)
cam.freeLook = false
cam.direction.x = -1
local angle = 0

while true do
    angle = angle + .01
    cam.direction.x = math.cos(angle)
    cam.direction.y = math.sin(angle)
    cam:calculateDirection()
    wait(.01)
end