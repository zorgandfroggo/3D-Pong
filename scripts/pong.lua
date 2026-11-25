local menuUI
local lives
local scoreUI
local scoreText
local endUI
local retryButton
local cube
local tag
local paddle
local paddleTag

local function mainMenu()
    menuUI = createWidget();
    menuUI.show = true
    menuUI.title = "Menu"
    menuUI.size.x = 1920
    menuUI.size.y = 1080
    local playButton = menuUI:createContext(uiContext.button, "Play");

    playButton.onClick = function()
        print("Clicked!")
        menuUI.show = false
    end
end

-- Functions

local function reset()
    tag.velocity.x = 10
    tag.velocity.y = 10
    paddle.position.y = 0
    endUI.show = false
    scoreUI.show = true
    lives = 3
    scoreText.text = lives
end

local function initializeAssets()
    -- Create UI

    lives = 3
    scoreUI = createWidget()
    scoreUI.show = true
    scoreUI.title = "Lives left"
    scoreUI.position.y = 500
    scoreText = scoreUI:createContext(uiContext.text, lives)

    endUI = createWidget()
    endUI.show = false
    endUI.title = "Game over"
    endUI.position.x = 100
    endUI.position.y = 100
    retryButton = endUI:createContext(uiContext.button, "Retry")

    retryButton.onClick = function()
        reset()
    end

    -- Create cube

    cube = createCube()
    tag = cube:createTag(tagType.physics)
    tag.gravity = false
    tag.velocity.x = 10
    tag.velocity.y = 10

    -- Create paddle

    paddle = createCube()
    paddle.scale.x = 3
    paddle.scale.y = .5
    paddle.position.x = 10
    paddle.rotation.z = 90
    paddleTag = paddle:createTag(tagType.physics)
    paddleTag.gravity = false
    paddleTag.static = true

    -- Create light

    local light = createPointLight()
    light.position.z = 5
    light.intensity = 5

    -- Create camera

    local cam = createCamera()
    cam.position.z = 30
    cam.freeLook = false
    cam.direction.z = -1
    cam.direction.y = 0
    cam.direction.x = 0
    cam:calculateDirection()
    setActiveCamera(cam)

    -- Create border

    local edge1 = createCube()
    edge1.baseColor.r = 0
    edge1.baseColor.b = 0
    edge1.baseColor.g = 0
    edge1.scale.x = 20
    edge1.position.y = 25
    local edgeTag1 = edge1:createTag(tagType.physics)
    edgeTag1.gravity = false
    edgeTag1.static = true

    local edge2 = createCube()
    edge2.baseColor.r = 0
    edge2.baseColor.b = 0
    edge2.baseColor.g = 0
    edge2.scale.x = 20
    edge2.position.y = -25
    local edgeTag2 = edge2:createTag(tagType.physics)
    edgeTag2.gravity = false
    edgeTag2.static = true

    local edge3 = createCube()
    edge3.baseColor.r = 0
    edge3.baseColor.b = 0
    edge3.baseColor.g = 0
    edge3.scale.y = 25
    edge3.position.x = -13
    local edgeTag3 = edge3:createTag(tagType.physics)
    edgeTag3.gravity = false
    edgeTag3.static = true
end

local function lifeLost()
    lives = lives - 1
    scoreText.text = lives
    cube.position.x = 0
    cube.position.y = 0
end

-- Game loop

function gameLoop()
    local initialized = false
    while true do
        if initialized and not menuUI.show and lives > 0 then
            local keys = captureKeyboard()
            if (keys[65]) and paddle.position.y >= -19 then
                paddle.position.y = paddle.position.y - .5
            end
            if (keys[68]) and paddle.position.y <= 19 then
                paddle.position.y = paddle.position.y + .5
            end

            if (cube.position.x >= 20) and lives > 0 then
                lifeLost()
            elseif (lives <= 0) then
                break
            end
        elseif not menuUI.show and not initialized then
            initialized = true
            initializeAssets()
        elseif initialized and lives <= 0 then
            endUI.show = true
            scoreUI.show = false
            tag.velocity.x = 0
            tag.velocity.y = 0
        end

        wait(.01)
    end
end

-- Start

function main()
    mainMenu();
    gameLoop()
end

main()