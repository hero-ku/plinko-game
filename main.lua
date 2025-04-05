local Vec2 = require("Vec2")

local PEG_RADIUS = 15
local PEG_SEGMENTS = 50
local GRAVITY = 300

local world = love.physics.newWorld(0, GRAVITY, true)

local unusedPegs = 0

local ballBody = love.physics.newBody(world, 400, 300, "dynamic")
local ballShape = love.physics.newCircleShape(PEG_RADIUS * 0.8)
local ballFixture = love.physics.newFixture(ballBody, ballShape)
ballFixture:setRestitution(1) -- bounce

local function dropBall()
    local x = math.random(0, love.graphics.getWidth())
    local y = 100

    ballBody:setLinearVelocity(0, 0)
    ballBody:setPosition(x, y)
    unusedPegs = unusedPegs + 1
end

local function drawPegPreview()
    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.circle("fill", mouseX, mouseY, PEG_RADIUS, PEG_SEGMENTS)
    love.graphics.setColor(1, 1, 1, 1)
end

local function getPegsInRadius(x, y)
    local pegs = {}
    local pos = Vec2.new(x, y)

    for _, body in ipairs(world:getBodies()) do
        if body:getType() ~= "static" then
            goto continue
        end

        local bodyPos = Vec2.new(body:getWorldCenter())
        if (pos - bodyPos):length() < PEG_RADIUS * 2 then
            table.insert(pegs, body)
        end
        ::continue::
    end

    return pegs
end

function love.load()
    love.graphics.setBackgroundColor(0.6, 0.3, 0.3)
    love.mouse.setVisible(false)
    love.window.setMode(800, 600, {
        resizable = false,
        vsync = 0, -- off
        highdpi = true,
    })

    dropBall()
end

function love.mousereleased()
    local mouseX, mouseY = love.mouse.getPosition()
    if #getPegsInRadius(mouseX, mouseY) > 0 or unusedPegs < 1 then return end
    unusedPegs = unusedPegs - 1

    local body = love.physics.newBody(world, mouseX, mouseY, "static")
    local shape = love.physics.newCircleShape(PEG_RADIUS)
    local fixture = love.physics.newFixture(body, shape)
end

function love.update(deltaTime)
    world:update(deltaTime)
    local ballX, ballY = ballBody:getPosition()
    local velX, velY = ballBody:getLinearVelocity()

    if ballX < PEG_RADIUS * 0.4 or ballX > love.graphics.getWidth() - PEG_RADIUS * 0.4 then
        ballBody:setLinearVelocity(-velX, velY)
    end

    if ballY > love.graphics.getHeight() then
        dropBall()
    end
end

function love.draw()
    drawPegPreview()

    for _, body in ipairs(world:getBodies()) do
        if body:getType() == "static" then
            -- is peg
            local x, y = body:getWorldCenter()
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", x, y, PEG_RADIUS, PEG_SEGMENTS)
        else
            -- is ball
            local x, y = body:getWorldCenter()
            love.graphics.setColor(0.2, 0.2, 0.8)
            love.graphics.circle("fill", x, y, PEG_RADIUS * 0.8, PEG_SEGMENTS)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end