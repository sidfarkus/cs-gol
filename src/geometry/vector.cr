struct Vector(T)
  property x, y, z

  def initialize(@x : T, @y : T, @z : T)
  end

  def length_sq
    x * x + y * y + z * z
  end

  def length
    Math.sqrt(length_sq)
  end

  def dot(other)
    x * other.x + y * other.y + z * other.z
  end

  def +(other)
    Vector(T).new(x + other.x, y + other.y, z + other.z)
  end

  def -(other)
    Vector(T).new(x - other.x, y - other.y, z - other.z)
  end
  
  def *(other)
    Vector(T).new(x * other.x, y * other.y, z * other.z)
  end

  def -
    Vector(T).new(-x, -y, -z)
  end
end

alias VectorF = Vector(Float32)
alias VectorD = Vector(Float64)