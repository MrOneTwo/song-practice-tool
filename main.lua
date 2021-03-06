require 'progress_bar'
require 'metronome'
require 'gui'

metronome:init('250552__druminfected__metronome.mp3')
beat:init(110)

state = {loopSegment = false, metronomeOn = true, tappingTempo = false, musicMuted = false}

VOLUME_MUSIC_DEFAULT = 0.8

local songProgressBar

imgCircleRedEmpty = love.graphics.newImage("circle_red_empty.png")
imgCircleRedFull = love.graphics.newImage("circle_red_full.png")

musicDecoder = love.sound.newDecoder('ed_sheeran_i_see_fire.mp3')
musicData = love.sound.newSoundData(musicDecoder)
music = love.audio.newSource(musicData)
music:setLooping(true)
music:setVolume(VOLUME_MUSIC_DEFAULT)
musicSampleCount = musicData:getSampleCount()


musicDurationStr = ""
beatTaps = {}
beatCursor = 0
--

beatsMap = {}
local musicCursor = 0

local pitch = 1.0

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end


function love.filedropped(file)
  n = file:getFilename()
  -- if string.match(n, "tiger") or string.match(file:getF) then
    -- print ("The word tiger was found.")
  -- else
    -- print ("The word tiger was not found.")
  -- end
end
 
function love.load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 1.0)
  songProgressBar = ProgressBar:new("song_progress_bar", gui.margin, cWindowHeight * 0.8, cWindowWidth * 0.8)
  segmentProgressBar = ProgressBar:new("segment_progress_bar", gui.margin, cWindowHeight * 0.6, cWindowWidth * 0.8)
  musicDurationStr = string.format("%02d:%02d",
                                   musicData:getDuration() / 60, musicData:getDuration() % 60)
  markerPair = MarkerPair:new("red", songProgressBar)
end

function love.update(dt)
  musicCursor = music:tell('samples')
  
  if state.loopSegment then
    -- Handle the cursor if it's outside of the segment.
    musicCursorPercentage = musicCursor / musicData:getSampleCount()
    if (musicCursorPercentage) > markerPair.mB.percentage then
      -- Rewind music to the start of the segment.
      musicCursor = musicData:getSampleCount() * markerPair.mA.percentage
      music:seek(musicCursor, 'samples')
    elseif (musicCursorPercentage) < markerPair.mA.percentage then
      musicCursor = musicData:getSampleCount() * markerPair.mA.percentage
      music:seek(musicCursor, 'samples')
    end
  end

  -- See if there is a tick value between the current music cursor and the previous one.
  local shouldTick = false

  for index, val in ipairs(beatsMap) do
    if val > musicCursorPrev and val < musicCursor then
      shouldTick = true
    end
  end

  if state.metronomeOn and shouldTick then
    metronome:play()
  end
  --

  musicCursorPrev = musicCursor
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
  love.graphics.print("BPM tapped: " .. beat.BPMTapped, 10, 64)
  love.graphics.print("Pitch: " .. pitch, 10, 80)

  -- Draw progress bars.
  songProgressBar:setProgress(musicCursor/musicData:getSampleCount())
  songProgressBar:draw()

  --TODO(michalc): fix this whole segment progress bar
  local segmentLengthPercent = markerPair:getEndPercentage() - markerPair:getStartPercentage()
  local segmentLengthSamples = segmentLengthPercent * musicData:getSampleCount()
  local segmentProgress = (musicCursor - (markerPair:getStartPercentage() * musicData:getSampleCount())) / segmentLengthSamples
  segmentProgressBar:setProgress(segmentProgress)
  segmentProgressBar:draw()

  -- Draw markers.
  if markerPair.active then
    markerPair:draw()
  end

  -- Draw markers' indicators at the bottom of the screen.
  if markerPair.mASet then
    love.graphics.draw(imgCircleRedEmpty, (cWindowWidth/2) - (imgCircleRedEmpty:getWidth() / 2) , cWindowHeight * 0.9)
  elseif not markerPair.mASet then
    love.graphics.draw(imgCircleRedFull, (cWindowWidth/2) - (imgCircleRedFull:getWidth() / 2), cWindowHeight * 0.9)
  end
  if markerPair.mBSet then
    love.graphics.draw(imgCircleRedEmpty, (cWindowWidth/2) - (imgCircleRedEmpty:getWidth() / 2) + 24, cWindowHeight * 0.9)
  elseif not markerPair.mBSet then
    love.graphics.draw(imgCircleRedFull, (cWindowWidth/2) - (imgCircleRedFull:getWidth() / 2) + 24, cWindowHeight * 0.9)
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
  elseif key == "1" then
    -- TODO(michalc): snap to beat when setting?
    markerPair:setMarkerA(musicCursor/musicData:getSampleCount())
    markerPair.active = true
  elseif key == "2" then
    markerPair:setMarkerB(musicCursor/musicData:getSampleCount())
    markerPair.active = true
  elseif key == "space" then
    if music:isPlaying() then
      music:pause()
    else
      music:play()
    end
  elseif key == "[" then
    markerPair:nudgeMarkerA(-1 * (beatStepInSec / musicData:getDuration()))
  elseif key == "]" then
    markerPair:nudgeMarkerA(beatStepInSec / musicData:getDuration())
  elseif key == "9" then
    pitch = pitch - 0.05
    pitch = math.clamp(0.5, pitch, 1.5)
    music:setPitch(pitch)
    print("slower")
  elseif key == "0" then
    pitch = pitch + 0.05
    pitch = math.clamp(0.5, pitch, 1.5)
    music:setPitch(pitch)
    print("faster")
  elseif key == "l" then
    state.loopSegment = (not state.loopSegment)
  elseif key == "n" then
    if state.musicMuted then
      music:setVolume(VOLUME_MUSIC_DEFAULT)
      state.musicMuted = false
    else
      music:setVolume(0.0)
      state.musicMuted = true
    end
  elseif key == "m" then
    state.metronomeOn = (not state.metronomeOn)
  elseif key == "t" then
    if love.keyboard.isDown( 'lalt' ) then
      state.tappingTempo = false
    else
      state.tappingTempo = true
    end

    if state.tappingTempo then
      table.insert(beatTaps, musicCursor)

      -- Create an array of beat deltas (distance between each inputted tap in samples).
      local deltas = {}
      if #beatTaps > 1 then
        beat.beatReferencePoint = beatTaps[1]
        for index = 1, #beatTaps - 1 do
          delta = beatTaps[index + 1] - beatTaps[index]
          table.insert(deltas, delta)
        end

        -- Average the deltas.
        local sum = 0
        for i, d in ipairs(deltas) do
          sum = sum + d
        end
        tapDeltaInSamples = sum / #deltas
        tapDeltaInSeconds = tapDeltaInSamples / musicData:getSampleRate()
        beat.BPMTapped = math.floor(60 / tapDeltaInSeconds)
        beat.beatDelta = beat:BPMToSamplesDelta(beat.BPMTapped, musicData:getSampleRate())
        beatCursor = beatTaps[#beatTaps]

        -- Build the beats map. It's important that it is relative to a tapped beat.
        beatsMapBeforeCursor = {}
        beatsMapAfterCursor = {}
        local stepIndex = 0

        -- Build the map before the cursor.
        repeat
          stepIndex = stepIndex + 1
          local beat = beatCursor - beat.beatDelta * stepIndex
          table.insert(beatsMapBeforeCursor, beat)
        until beat < 0

        -- Build the map after the cursor.
        stepIndex = 0
        repeat
          stepIndex = stepIndex + 1
          local beat = beatCursor + beat.beatDelta * stepIndex
          table.insert(beatsMapAfterCursor, beat)
        until #beatsMapAfterCursor > 500

        beatsMap = {unpack(beatsMapBeforeCursor), beatCursor, unpack(beatsMapAfterCursor)}
      end
    end
  end -- if key == ...

end -- function love.keypressed
