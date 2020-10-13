require "../spec_helper"

matrix(1, 2, Int32)
matrix(2, 1, Int32)
matrix(2, 2, Int32)
matrix(3, 3, Float32)

alias Matrix3 = Matrix3x3

class Matrix3Producer < Producer(Matrix3)
  def produce(trial, options) : Matrix3
    random = Random.new
    Matrix3.new((0...9).map { |_| random.rand(numeric_limits["Float32"]).to_f32 })
  end
end

describe "Matrix" do
  prop transpose_is_symmetric, m.transpose.transpose == m, m : Matrix3
  prop multiply_by_identity_is_original, m * Matrix3.identity == m, m : Matrix3

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

  it "generates an identity class method" do
    m = Matrix3.identity
    m.should eq(
      Matrix3.new(1.0, 0.0, 0.0,
                  0.0, 1.0, 0.0,
                  0.0, 0.0, 1.0))
  end

  it "allows access to the matrix columns" do
    m = Matrix3.new(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
    m.cols.should eq([[1.0, 4.0, 7.0],
                      [2.0, 5.0, 8.0],
                      [3.0, 6.0, 9.0]])
  end

  it "allows access to the matrix rows" do
    m = Matrix3.new(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
    m.rows.should eq([[1.0, 2.0, 3.0],
                      [4.0, 5.0, 6.0],
                      [7.0, 8.0, 9.0]])
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

    a, b = Matrix3.identity, Matrix3.new(2.0, 3.0, 4.0,
             2.0, 3.0, 4.0,
             2.0, 3.0, 4.0)
    (a * b).should eq(b)
  end
end
