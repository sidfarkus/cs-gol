struct Quaternion(T)
    property x, y, z, w

    def initialize(@x : T, @y : T, @z : T, @w : T)
    end

    def length_sq
      x * x + y * y + z * z + w * w
    end

    def length
      Math.sqrt(length_sq)
    end

    def dot(other)
      x * other.x + y * other.y + z * other.z
    end

    def +(other)
    end

    def -(other)
    end

    def *(other)
    end

    def -
    end
  end
