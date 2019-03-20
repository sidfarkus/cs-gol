require "../spec_helper"

describe "vector" do
  it "can calculate its squared length" do
    v = VectorF.new(1.0, 2.0, 3.0)
    v.length_sq.should be_close(14.0, 0.0001)
  end

  it "can calculate the actual vector length" do
    v = VectorF.new(2.0, 3.0, 2.0)
    v.length.should be_close(4.1231, 0.0001)
  end

  it "supports dot product" do
    v1, v2 = VectorF.new(1.0, 2.0, 1.0), VectorF.new(1.0, 1.0, 3.0)
    v1.dot(v2).should be_close(6.0, 0.0001)
  end

  it "supports cross product" do
    v1, v2 = VectorF.new(1.0, 2.0, 1.0), VectorF.new(1.0, 1.0, 3.0)
    v1.cross(v2).close?(VectorF.new(5.0, -2.0, -1.0)).should be_true
  end
end
