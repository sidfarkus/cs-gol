struct Quaternion(T)
  property x, y, z, w

  def initialize(@x : T, @y : T, @z : T, @w : T)
  end

  def initialize(real : T, vec : Vector(T))
    @x = vec.x
    @y = vec.y
    @z = vec.z
    @w = real
  end

  def length_sq
    x * x + y * y + z * z + w * w
  end

  def length
    Math.sqrt(length_sq)
  end

  def norm!
    len = length
    @x /= len
    @y /= len
    @z /= len
    @w /= len
  end

  def norm
    len = length
    Quaternion(T).new(
      @x / len,
      @y / len,
      @z / len,
      @w / len
    )
  end

  def vec_part
    Vector(T).new(
      @x,
      @y,
      @z
    )
  end

  def conj
    Quaternion(T).new(
      -@x,
      -@y,
      -@z,
      @w
    )
  end

  def inverse
    len = length_sq
    Quaternion(T).new(
      -@x / len,
      -@y / len,
      -@z / len,
      @w / len
    )
  end

  def *(other : Quaternion(T))
    cross = vec_part.cross(other.vec_part)
    Quaternion(T).new(
      @x * other.w + other.x * @w + cross.x,
      @y * other.w + other.y * @w + cross.y,
      @z * other.w + other.z * @w + cross.z,
      @w * other.w - vec_part.dot(other.vec_part)
    )
  end

  def *(scale : T)
    Quaternion(T).new(
      @x * scale,
      @y * scale,
      @z * scale,
      @w * scale
    )
  end

  def dot(other : Quaternion(T))
    @x * other.x + @y * other.y + @z * other.z + @w * other.w
  end

  def close?(other : Quaternion(T), delta : T)
    (other.x - @x).abs <= delta &&
    (other.y - @y).abs <= delta &&
    (other.z - @z).abs <= delta &&
    (other.w - @w).abs <= delta
  end

  def lerp(destination : Quaternion(T), time : T) : Quaternion(T)
    t1 = T.new(1.0) - time;
    dot = self.dot(destination)
    if dot >= 0
      Quaternion(T).new(
        t1 * @x + time * destination.x,
        t1 * @y + time * destination.y,
        t1 * @z + time * destination.z,
        t1 * @w + time * destination.w
      )
    else
      Quaternion(T).new(
        t1 * @x - time * destination.x,
        t1 * @y - time * destination.y,
        t1 * @z - time * destination.z,
        t1 * @w - time * destination.w
      )
    end
  end

  def slerp(destination : Quaternion(T), time : T) : Quaternion(T)
    dot = self.dot(destination).clamp(-1.0, 1.0)

    # Quaternions are too close, just lerp
    return self.lerp(destination, time) if dot > 0.9995

    theta = Math.acos(dot) * t # angle between v0 and result

    v2 = destination – self * dot;
    self * cos(theta) + v2 * sin(theta);
  end

  def self.identity
    Quaternion(T).new(
      0,
      0,
      0,
      1
    )
  end

  def self.zero
    Quaternion(T).new(
      0,
      0,
      0,
      0
    )
  end
end

alias QuaternionF = Quaternion(Float32)
alias QuaternionD = Quaternion(Float64)
