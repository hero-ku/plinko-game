local Vec2 = require("Vec2")

local backgroundImage = love.graphics.newImage("assets/plinkoBackground.png")

local PEG_RADIUS = 15
local PEG_SEGMENTS = 50
local GRAVITY = 500
local BOUNCE = 1

local world = love.physics.newWorld(0, GRAVITY, true)

local pegCost = 1
local money = 5
local baseCollected = 0
local unusedPegs = 0
local pegPositions = {}
local multipliers = {1,2,5,2,1}

local ballBody = love.physics.newBody(world, 400, 300, "dynamic")
local ballShape = love.physics.newCircleShape(PEG_RADIUS * 0.8)
local ballFixture = love.physics.newFixture(ballBody, ballShape)
ballFixture:setRestitution(BOUNCE) -- bounce

local function processCollision(fixture1, fixture2, contact)
    if fixture1 == ballFixture or fixture2 == ballFixture then
        local otherFixture = fixture1 == ballFixture and fixture2 or fixture1
        otherFixture:getBody():destroy()
        baseCollected = baseCollected + 1
    end
end

local function dropBall()
    local width = love.graphics.getWidth()

    local x = width / 2 + math.random(-width / 4,  width / 4)
    local y = 100

    ballBody:setLinearVelocity(0, 0)
    ballBody:setPosition(x, y)
end

local function createPeg(position)
    local body = love.physics.newBody(world, position.x, position.y, "static")
    local shape = love.physics.newCircleShape(PEG_RADIUS)
    local fixture = love.physics.newFixture(body, shape)
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
        msaa = 16,
        highdpi = true,
    })

    world:setCallbacks(processCollision)
    dropBall()
end

function love.mousereleased()
    local mouseX, mouseY = love.mouse.getPosition()
    if #getPegsInRadius(mouseX, mouseY) > 0 or money < pegCost then return end
    local pos = Vec2.new(mouseX, mouseY)
    table.insert(pegPositions, pos)
    createPeg(pos)
    money = money - pegCost
    pegCost = math.ceil(pegCost^1.5) + 1
end


function love.update(deltaTime)
    world:update(deltaTime)
    local ballX, ballY = ballBody:getPosition()
    local velX, velY = ballBody:getLinearVelocity()

    if ballX < PEG_RADIUS * 0.4 or ballX > love.graphics.getWidth() - PEG_RADIUS * 0.4 then
        ballBody:setLinearVelocity(-velX, velY)
    end

    if ballY > love.graphics.getHeight() then
        local slot = math.ceil(ballX / love.graphics.getWidth() * 5)
        money = money + baseCollected * multipliers[slot]
        baseCollected = 0

        for _, body in ipairs(world:getBodies()) do
            if body:getType() == "static" then
                body:destroy()
            end
        end

        for _, position in ipairs(pegPositions) do
            createPeg(position)
        end

        dropBall()
    end
end

function love.draw()
    love.graphics.draw(backgroundImage)
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

    local width, height = love.graphics.getDimensions()
    for i = 0, 4 do
        love.graphics.print(multipliers[i+1] .. "x", i * width/5 + width/10 - 5, height - 50)

        if i > 0 then
            love.graphics.rectangle("fill", i * width/5, height - 100, 1, 100)
        end
    end

    love.graphics.print("Money: " .. money, 100, 100)
    love.graphics.print("Collected: " .. baseCollected, 100, 120)
    love.graphics.print("Peg Cost: " .. pegCost, 100, 140)
    love.graphics.print("Un-used Pegs: " .. unusedPegs, 100, 160)
end