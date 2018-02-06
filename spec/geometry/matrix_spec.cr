require "../spec_helper"

matrix(1, 2, Int32)
matrix(2, 1, Int32)

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

  it "generates a transpose function that can transpose the array" do
    m = Matrix1x2.new(2, 3)
    m.transpose.should eq(Matrix2x1.new(2, 3))

    m = Matrix3.new((0...9).map(&.to_f32))
    m.transpose.should eq(Matrix3.new([0, 3, 6, 1, 4, 7, 2, 5, 8].map(&.to_f32)))
    puts m
  end

  it "generates an exception for transpose! when provided a non-square matrix" do
    m = Matrix2x1.new(1, 2)
    expect_raises do 
      m.transpose!
    end
  end

  it "generates a multiplication function that multiplies a matrix" do
    a, b = Matrix2x1.new(4, 5), Matrix1x2.new(6, 3)
    (a * b).should eq(Matrix1x1.new(39))
  end
end
