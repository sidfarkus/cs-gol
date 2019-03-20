require "../spec_helper"

matrix(1, 2, Int32)
matrix(2, 1, Int32)
matrix(2, 2, Int32)
matrix(3, 3, Float32)

alias Matrix3 = Matrix3x3

describe "matrix" do
  it "generates a Matrix class of appropriate dims" do
    m = Matrix1x2.zeros
    m.row_count.should eq(1)
    m.col_count.should eq(2)
  end

  it "generates a constructor that can take varargs" do
    m = Matrix1x2.new(1, 2)
    m[0].should eq(1)
    m[1].should eq(2)
  end

  it "generates a constructor that can take a data array" do
    m = Matrix2x1.new([2, 3])
    m[0].should eq(2)
    m[1].should eq(3)
  end

  it "generates a zeros class method" do
    m = Matrix2x1.zeros
    m.should eq(Matrix2x1.new(0, 0))
  end

  it "generates a transpose function that can transpose the array" do
    m = Matrix1x2.new(2, 3)
    m.transpose.should eq(Matrix2x1.new(2, 3))

    m = Matrix3.new((0...9).map(&.to_f32))
    m.transpose.should eq(Matrix3.new([0, 3, 6, 1, 4, 7, 2, 5, 8].map(&.to_f32)))
  end

  it "generates an exception for transpose! when provided a non-square matrix" do
    m = Matrix2x1.new(1, 2)
    expect_raises(Exception) do
      m.transpose!
    end
  end

  it "generates a multiplication function that multiplies a matrix" do
    a, b = Matrix2x1.new(4, 5), Matrix1x2.new(6, 3)
    (a * b).should eq(Matrix2x2.new(24, 12, 30, 15))
  end
end
