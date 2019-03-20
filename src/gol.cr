require "glfw"

require "./*"
require "./rendering/*"
require "./geometry/*"


include CrystGLFW

# Initialize GLFW
CrystGLFW.run do
  # Create a new window.
  window = Window.new(title: "My First Window")

  # Configure the window to print its dimensions each time it is resized.
  window.on_resize do |event|
    puts "Window resized to #{event.size}"
  end

  # Make this window's OpenGL context the current drawing context.
  window.make_context_current

  until window.should_close?
    CrystGLFW.wait_events
    window.swap_buffers
  end
end    
   
