require 'progress_bar'

local songProgressBar

local margin = 64

musicDecoder = love.sound.newDecoder('milky_chance_dont_let_me_down.mp3')
musicData = love.sound.newSoundData(musicDecoder)
music = love.audio.newSource(musicData)
music:setLooping(true)
music:play()
musicSampleCount = musicData:getSampleCount()

musicDurationStr = ""


function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

 
function love.load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 1.0)
  songProgressBar = ProgressBar:new("song_progress_bar", margin, cWindowHeight * 0.8, cWindowWidth * 0.8)
  segmentProgressBar = ProgressBar:new("segment_progress_bar", margin, cWindowHeight * 0.6, cWindowWidth * 0.8)
  musicDurationStr = string.format("%02d:%02d",
                                   musicData:getDuration() / 60, musicData:getDuration() % 60)
  markerPair = MarkerPair:new("red", songProgressBar)
end

function love.update(dt)
  musicCursor = music:tell('samples')
end

function love.draw()
  -- Draw debug info.
  love.graphics.setColor(0.7, 0.7, 0.7, 1.0)
  love.graphics.print("0:00", songProgressBar.posX - 32, songProgressBar.posY)
  love.graphics.print(musicDurationStr,
                      songProgressBar.posX + songProgressBar.width,
                      songProgressBar.posY)
                      
  love.graphics.setColor(0.0, 1.0, 0.3, 1.0)
  love.graphics.print(musicCursor, 10, 10)
  love.graphics.print(musicData:getSampleCount(), 10, 24)
  love.graphics.print(musicCursor/musicData:getSampleRate(), 10, 48)

  -- Draw progress bars.
  songProgressBar:setProgress(musicCursor/musicData:getSampleCount())
  songProgressBar:draw()

  --TODO(michalc): fix this whole segment progress bar
  segmentLengthPercent = markerPair:getEndPercentage() - markerPair:getStartPercentage()
  segmentLengthSamples = segmentLengthPercent * musicData:getSampleCount()
  segmentProgress = (musicCursor - (markerPair:getStartPercentage() * musicData:getSampleCount())) / segmentLengthSamples
  segmentProgressBar:setProgress(segmentProgress)
  segmentProgressBar:draw()

  -- Draw markers.
  if markerPair.active then
    markerPair:draw()
  end
  
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  elseif key == "left" then
    musicCursor = musicCursor - musicData:getSampleRate()
    musicCursor = math.clamp(0, musicCursor, musicData:getSampleCount())
    music:seek(musicCursor, 'samples')
  elseif key == "right" then
    musicCursor = musicCursor + musicData:getSampleRate()
    musicCursor = math.clamp(0, musicCursor, musicData:getSampleCount())
    music:seek(musicCursor, 'samples')
  elseif key == "m" then
    markerPair:setMarker(musicCursor/musicData:getSampleCount())
    markerPair.active = true
  elseif key == "space" then
    if music:isPlaying() then
      music:pause()
    else
      music:play()
    end
  end
end
