module QuaternionBuilder
    extend self

    # Create a rotation from an axis and an angle to rotate around the axis
    def from_axis_angle(axis : VectorF, angle : Float32)
        half_angle = angle / 2.0_f32
        sin_half_angle = Math.sin(half_angle)
        QuaternionF.new(
            axis.x * sin_half_angle,
            axis.y * sin_half_angle,
            axis.z * sin_half_angle,
            Math.cos(half_angle)
        )
    end

    # Create a rotation from a given vector to another vector.
    def from_to_rotation(vector1 : VectorF, vector2 : VectorF)
        axis = vector1.cross(vector2).norm!
        from_axis_angle(axis, vector1.angle(vector2))
    end
end