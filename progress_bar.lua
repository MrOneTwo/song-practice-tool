ProgressBar = {name = "ble",
               posX = 0, posY = 0,
               width = cWindowWidth, height = 24,
               progress = 0.0}
               

function ProgressBar:new(name, posX, posY, width)
  local ret = {}
  ret.name = name
  ret.posY = posY
  ret.posX = posX
  ret.width = width
  setmetatable(ret, self)
  self.__index = self
  return ret
end

function ProgressBar:draw()
  love.graphics.setColor(0.5, 0.5, 0.5, 1.0)
  love.graphics.rectangle("fill",
                          self.posX, self.posY,
                          self.width, self.height);
  love.graphics.setColor(0.7, 0.7, 0.7, 1.0)
  love.graphics.rectangle("fill",
                          self.posX, self.posY,
                          self.width * self.progress, self.height);
end

function ProgressBar:setProgress(progress)
  self.progress = progress
end


Marker = {name = "ble", posX = 0, posY = 0, percentage = 0}

function Marker:new(name, posX, posY)
  local ret = {}
  ret.name = name
  ret.posX = posX;
  ret.posY = posY;
  setmetatable(ret, self)
  self.__index = self
  return ret
end

function Marker:draw()
  local verts = {
    self.posX + 0, self.posY + 0,
    self.posX + 9, self.posY + 16,
    self.posX - 9, self.posY + 16
  }
  love.graphics.setColor(0.7, 0.0, 0.0, 1.0)
  love.graphics.polygon('fill', verts)
end

function Marker:setPercentage(perc)
  self.percentarge = perc
end


MarkerPair = {name = "...", parentBar = nil, mA = nil, mB = nil, active = false, mASet = false, mBSet = false}

function MarkerPair:new(name, parentBar)
  local ret = {}
  ret.name = name
  ret.parentBar = parentBar
  ret.mA = Marker:new('mA', parentBar.posX, parentBar.posY + parentBar.height)
  ret.mB = Marker:new('mB', parentBar.posX, parentBar.posY + parentBar.height)
  setmetatable(ret, self)
  self.__index = self
  return ret
end

function MarkerPair:draw()
  self.mA:draw()
  self.mB:draw()
end

function MarkerPair:setMarkerA(percentage)
  self.mA:setPercentage(percentage)
  self.mA.posX = self.parentBar.posX + percentage * self.parentBar.width
  self.mASet = true
end

function MarkerPair:setMarkerB(percentage)
  self.mB:setPercentage(percentage)
  self.mB.posX = self.parentBar.posX + percentage * self.parentBar.width
  self.mBSet = true
end

function MarkerPair:setMarker(percentage)
  if self.mASet == false and self.mBSet == false then
    self:setMarkerA(percentage)
  elseif self.mASet == true and self.mBSet == false then
    self:setMarkerB(percentage)
  elseif self.mASet == false and self.mBSet == true then
    self:setMarkerA(percentage)
  else if self.mASet == true and self.mBSet == true then
  end
  end
end

function MarkerPair:getStartPercentage()
  return self.mA.percentage
end

function MarkerPair:getEndPercentage()
  return self.mB.percentage
end
