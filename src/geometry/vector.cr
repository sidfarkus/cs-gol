
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
    @x * other.x + @y * other.y + @z * other.z
  end

  def cross(other)
    Vector(T).new(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x
    )
  end

  def +(other : Vector(T) | T)
    if other.is_a?(Vector(T))
      Vector(T).new(x + other.x, y + other.y, z + other.z)
    else
      Vector(T).new(x + other, y + other, z + other)
    end
  end

  def -(other : Vector(T) | T)
    if other.is_a?(Vector(T))
      Vector(T).new(x - other.x, y - other.y, z - other.z)
    else
      Vector(T).new(x - other, y - other, z - other)
    end
  end

  def *(other : Vector(T) | T)
    if other.is_a?(Vector(T))
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

    (x - other.x).abs <= delta_f &&
    (y - other.y).abs <= delta_f &&
    (z - other.z).abs <= delta_f
  end

  def angle(other : Vector(T))
    Math.acos(self.norm.dot(other.norm).clamp(-1.0, 1.0))
  end

  def rotate(quaternion : Quaternion(T))
    x2 = quaternion.x + quaternion.x
    y2 = quaternion.y + quaternion.y
    z2 = quaternion.z + quaternion.z

    wx2 = quaternion.w * x2
    wy2 = quaternion.w * y2
    wz2 = quaternion.w * z2
    xx2 = quaternion.x * x2
    xy2 = quaternion.x * y2
    xz2 = quaternion.x * z2
    yy2 = quaternion.y * y2
    yz2 = quaternion.y * z2
    zz2 = quaternion.z * z2

    Vector(T).new(
      @x * (1.0 - yy2 - zz2) + @y * (xy2 - wz2) + @z * (xz2 + wy2),
      @x * (xy2 + wz2) + @y * (1.0 - xx2 - zz2) + @z * (yz2 - wx2),
      @x * (xz2 - wy2) + @y * (yz2 + wx2) + @z * (1.0 - xx2 - yy2)
    )
  end

  def self.zero()
    Vector(T).new(0, 0, 0)
  end

  def self.x_axis()
    Vector(T).new(1, 0, 0)
  end

  def self.y_axis()
    Vector(T).new(0, 1, 0)
  end

  def self.z_axis()
    Vector(T).new(0, 0, 1)
  end
end

alias VectorF = Vector(Float32)
alias VectorD = Vector(Float64)
