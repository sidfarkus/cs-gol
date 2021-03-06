require "../spec_helper"

class VectorFProducer < Producer(VectorF)
  def produce(trial, options) : VectorF
    random = Random.new
    VectorF.new(
      random.rand(numeric_limits["Float32"]).to_f32,
      random.rand(numeric_limits["Float32"]).to_f32,
      random.rand(numeric_limits["Float32"]).to_f32
      )
  end
end

describe "vector" do
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
end
