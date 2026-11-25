local entities = captureEntities()
local cameras = entities.cameras

if cameras:size() > 0 then
    local cam = cameras[0]
    print(cam)
end