# A 3D vector class suitable for use with any numeric type
struct Vector(T)
  property x, y, z

  def initialize(@x : T, @y : T, @z : T)
  end

  def initialize(data : Array(T))
    @x, @y, @z = data
  end

  def to_a
    [x, y, z]
  end

  def length_sq
    x * x + y * y + z * z
  end

  def length
    Math.sqrt(length_sq)
  end

  def norm!
    len = length
    @x /= len
    @y /= len
    @z /= len
    self
  end

  def norm
    Vector(T).new(x, y, z).norm!
  end

  def dot(other)
    (self * other).to_a.sum
  end

  def cross(other)
    Vector(T).new(y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x)
  end

  def +(other)
    if other.responds_to?(:x)
      Vector(T).new(x + other.x, y + other.y, z + other.z)
    else
      Vector(T).new(x + other, y + other, z + other)
    end
  end

  def -(other)
    if other.responds_to?(:x)
      Vector(T).new(x - other.x, y - other.y, z - other.z)
    else
      Vector(T).new(x - other, y - other, z - other)
    end
  end

  def *(other)
    if other.responds_to?(:x)
      Vector(T).new(x * other.x, y * other.y, z * other.z)
    else
      Vector(T).new(x * other, y * other, z * other)
    end
  end

  def -
    Vector(T).new(-x, -y, -z)
  end

  def close?(other : Vector(T), delta = 0.001)
    delta_f = T.new(delta)
    (x - other.x).abs <= delta_f && (y - other.y).abs <= delta_f && (z - other.z).abs <= delta_f
  end

  def rotate(quaternion : Quaternion(T))
  end
end

alias VectorF = Vector(Float32)
alias VectorD = Vector(Float64)
