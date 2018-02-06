require "glfw"
require "gl"

require "./*"
require "./rendering/*"
require "./geometry/*"

hints = {
  LibGLFW3::OPENGL_PROFILE => LibGLFW3::OPENGL_CORE_PROFILE,
  LibGLFW3::OPENGL_FORWARD_COMPAT => 1,
  LibGLFW3::CONTEXT_VERSION_MAJOR => 3,
  LibGLFW3::CONTEXT_VERSION_MINOR => 3
}

window = GLFW::Window.new(1024, 600, "Game of life", hints)

window.make_current

GLFW.swap_interval = 1
GL.clear_color(0.3, 0.65, 0.8, 1.0)

until window.should_close?
  GL.clear(GL::BufferBit::Color | GL::BufferBit::Depth)

  
  window.swap_buffers
  GLFW.poll_for_events
end