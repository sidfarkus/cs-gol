require "../spec_helper"

class VectorFProducer < Producer(VectorF)
  def produce(trial, options) : VectorF
    random = Random.new
    if !options[:nonzero_only]? && random.next_int % 10 == 0
      VectorF.zero
    else
      producer = Float32Producer.new
      floats = (0..2).map {|i| producer.produce(trial, options)}
      VectorF.new(*Tuple(Float32, Float32, Float32).from(floats))
    end
  end
end

describe Vector do
  prop(:dot_product_with_zero_is_zero, v : VectorF) {|v| v.dot(VectorF.zero) == 0 }

  prop(:cross_product_is_orthogonal, v1 : VectorF, v2 : VectorF, {nonzero_only: true}) do |v1, v2|
    v1.cross(v2).angle(v1).should be_close(Math::PI / 2.0, 0.0001)
  end

  prop(:rotation_by_arbitrary_quaternion, v1 : VectorF, axis : VectorF, {nonzero_only: true}) do |v1, axis|
    angle = Random.new.next_float * Math::PI / 2.0
    axis.norm!
    rotated = v1.rotate(QuaternionBuilder.from_axis_angle(axis, angle.to_f32))
    rotate_back = rotated.rotate(QuaternionBuilder.from_axis_angle(axis, -angle.to_f32))
    rotate_back.angle(v1).should be_close(0, 0.001)
  end

  prop(:angle_calculation_is_symmetric, v : VectorF, {nonzero_only: true}) do |v|
    angle = Random.new.next_float * Math::PI
    rotated = v.rotate(QuaternionBuilder.from_axis_angle(VectorF.x_axis, angle.to_f32))
    v.angle(rotated).should be_close(rotated.angle(v), 1e-7)
  end

  it "can calculate its squared length" do
    v = VectorF.new(1.0, 2.0, 3.0)
    v.length_sq.should be_close(14.0, 0.0001)
  end

  it "can calculate the actual vector length" do
    v = VectorF.new(2.0, 3.0, 2.0)
    v.length.should be_close(4.1231, 0.0001)
  end

  it "can be normalized" do
    v = VectorF.new(10.0, 0.0, 0.0)
    v.norm.length.should be_close(1.0, 0.0001)
    v.norm.close?(VectorF.new(1.0, 0, 0)).should be_true
  end

  it "supports dot product" do
    v1, v2 = VectorF.new(1.0, 2.0, 1.0), VectorF.new(1.0, 1.0, 3.0)
    v1.dot(v2).should be_close(6.0, 0.0001)
  end

  it "supports cross product" do
    v1, v2 = VectorF.new(1.0, 2.0, 1.0), VectorF.new(1.0, 1.0, 3.0)
    v1.cross(v2).close?(VectorF.new(5.0, -2.0, -1.0)).should be_true
  end

  it "can be scaled by an arbitrary value" do
    v = VectorF.new(1.0, 1.0, 1.0)
    (v * 3.0).close?(VectorF.new(3.0, 3.0, 3.0)).should be_true
  end

  it "can find the angle between a vector and another in radians" do
    axes = [VectorF.x_axis, VectorF.y_axis, VectorF.z_axis]
    axes.each_permutation(2) do |(a1, a2)|
      a1.angle(a2).should be_close(Math::PI / 2, 0.0001)
    end
  end
end
