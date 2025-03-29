local Vec2 = {}
Vec2.__index = Vec2

function Vec2.new(x, y)
    local self = setmetatable({}, Vec2)
    self.x = x or 0
    self.y = y or 0
    return self
end

function Vec2:length()
    return math.sqrt(self.x^2 + self.y^2)
end

function Vec2:unit()
    local len = self:length()
    if len == 0 then
        return Vec2.new(0, 0)
    end
    return Vec2.new(self.x / len, self.y / len)
end

function Vec2:angle()
    return math.atan(self.y, self.x)
end

function Vec2:__add(other)
    return Vec2.new(self.x + other.x, self.y + other.y)
end

function Vec2:__sub(other)
    return Vec2.new(self.x - other.x, self.y - other.y)
end
function Vec2:__mul(scalar)
    return Vec2.new(self.x * scalar, self.y * scalar)
end
function Vec2:__div(scalar)
    return Vec2.new(self.x / scalar, self.y / scalar)
end

function Vec2:__tostring()
    return string.format("Vec2(%f, %f)", self.x, self.y)
end

return Vec2