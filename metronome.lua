metronome = {filepath = '', decoder = nil, soundData = nil, audio = nil}

VOLUME_METRONOME_DEFAULT = 0.2


function metronome:init(filepath)
  self.filepath = filepath
  self.decoder = love.sound.newDecoder(filepath)
  self.soundData = love.sound.newSoundData(self.decoder)
  self.audio = love.audio.newSource(self.soundData)
  self.audio:setVolume(VOLUME_METRONOME_DEFAULT)
  self.audio:setLooping(false)
end

function metronome:play()
  self.audio:play()
end

function metronome:mute()
  self.audio:setVolume(0.0)
end

function metronome:unmute()
  self.audio:setVolume(VOLUME_METRONOME_DEFAULT)
end

beat =
  {BPM = 0,                -- Beats Per Minute.
   BPMTapped = 0,          -- Beats Per Minute from user tapping a button.
   beatReferencePoint = 0, -- Reference point (in samples) from which beats map gets computed.
   beatDelta = 0}          -- Distance between two beats in samples.

function beat:init(BPM)
  self.BPM = BPM
end

function beat:BPMToBPS()
  return self.BPM / 60
end

function beat:BPMToBPSong(durationInSec)
  return self:BPMToBPS() * durationInSec
end

function beat:BeatStepInSec(durationInSec)
  return durationInSec / self:BPMToBPSong(durationInSec)
end

function beat:BeatStepInSamp(durationInSamples)
  return durationInSamples / self:BPMToBPSong(durationInSamples)
end

function beat:BPMToSamplesDelta(BPM, totalSamplesCount)
  local BPS = BPM / 60
  return (1 / BPS) * totalSamplesCount
end
