cWindowWidth = 800
cWindowHeight = 600

function love.conf(t)
  t.identity = nil
  t.version = "11.3"

  t.window.title = "Song practicer"
  t.window.width = cWindowWidth
  t.window.height = cWindowHeight
  t.window.resizable = false
  t.window.fullscreen = false

  t.modules.audio = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = false
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = false
  t.modules.sound = true
  t.modules.system = true
  t.modules.timer = true
  t.modules.window = true
  t.modules.thread = true
end
