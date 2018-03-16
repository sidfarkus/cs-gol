require "crystglfw"
require "gl"

require "./*"
require "./rendering/*"
require "./geometry/*"

GL.clear_color(0.3, 0.65, 0.8, 1.0)

CrystGLFW.run do
  window = CrystGLFW::Window.new(title: "Game of Life", width: 1024, height: 600)

  window.on_resize do |event|
    puts "Window resized to #{event.size}"
  end

  window.make_context_current

  until window.should_close?
    CrystGLFW.wait_events
    GL.clear(GL::BufferBit::Color | GL::BufferBit::Depth)
    
    window.swap_buffers
  end

  window.destroy
end