local cube1 = createCube()
local cube2 = createCube()
local ground = createCube()
local pointLight = createPointLight()

pointLight.intensity = 5
pointLight.position.z = 5

ground.scale.x = 10
ground.scale.z = 0.01
ground.scale.y = 10
ground.position.z = -2

local tagGround = ground:createTag(1)
tagGround.static = true

cube1.position.x = -5
cube2.position.x = 5

local tag1 = cube1:createTag(1)
local tag2 = cube2:createTag(1)

tag1.acceleration.x = 5
tag2.acceleration.x = -5

tag1.mass = 3