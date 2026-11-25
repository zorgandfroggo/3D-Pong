local val = captureEntities().spotlights:size()

if val > 0 then
    local light = captureEntities().spotlights[0]

    while true do
        light.rotation.z = light.rotation.z + 1
        wait(.01)
    end
end