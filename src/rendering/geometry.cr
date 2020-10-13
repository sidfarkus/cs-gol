require "lib_gl"

class Geometry
  getter buffer, vertices
  class_getter bound

  @buffer = 0_u32
  @vertices = [] of Array(Float32)
  @@bound = 0_u32

  def initialize
    @buffer = GL.gen_buffer
  end

  def vertices=(data : Array(Float))
    @vertices = data
    GL.buffer_data(GL::BufferBindingTarget::Array, vertices.count, vertices, LibGL::STATIC_DRAW)
  end

  def bind
    GL.bind_buffer(GL::BufferBindingTarget::Array, @buffer)
  ensure
    @@bound = @buffer
  end

  def finalize
    GL.delete_buffer(@buffer)
  end
end
