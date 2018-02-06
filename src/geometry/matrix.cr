macro matrix(rows, cols, kind)
  class Matrix{{rows}}x{{cols}}
    property data

    macro transposition(input, output)
      {% for row in 0...rows %}
      {% for col in 0...cols %}
      \{{output}}[{{col * rows + row}}] = \{{input}}[{{row * cols + col}}]
      {% end %}
      {% end %}
    end

    def self.zeros
      Matrix{{rows}}x{{cols}}.new([
        {% for row in 0...rows %}
        {% for col in 0...cols %}
        {{kind}}.new(0),
        {% end %}
        {% end %}
      ])
    end

    def initialize(data : Array({{kind}}))
      @data = data
    end

    def initialize(*args : {{kind}})
      @data = [
      {% for row in 0...rows %}
      {% for col in 0...cols %}
      args[{{row * cols + col}}],
      {% end %}
      {% end %}
      ]
    end

    def [](i)
      @data[i]
    end

    def [](row, col)
      @data[row * {{cols}} + col]
    end

    def rows
      @data.each_slice(row_count, true)
    end

    def cols
      (0..col_count).each do |col|
      end
    end

    def transpose
      flipped = @data.clone
      transposition(@data, flipped)
      Matrix{{cols}}x{{rows}}.new(flipped)
    end

    def transpose!
      {% if rows != cols %}
      raise Exception.new("In place transpose must have a square matrix!")
      {% else %}
      transposition(@data, @data)
      {% end %}
    end

    def row_count
      {{rows}}
    end

    def col_count
      {{cols}}
    end

    def *(other)
      raise Exception.new if other.col_count != row_count
      output = Matrix{{rows}}x{{rows}}.zeros
      {% for row in 0...rows %}
      {% for col in 0...rows %}
      output[{{row}}, {{col}}] = other.cols[{{col}}].zip(rows[{{row}}]).map {|a, b| a * b}.reduce(&:+)
      {% end %}
      {% end %}
      output     
    end

    def ==(other)
      return false if other.col_count != col_count || other.row_count != row_count
      return @data == other.data
    end

    def to_s
      "{% for row in 0...rows %}[{% for col in 0...cols %}#{self[{{row}},{{col}}]}{% if col != cols - 1 %}, {% end %}{% end %}]\n{% end %}"
    end

    def to_s(io)
      io << to_s
    end
  end
end

matrix(2, 2, Float32)
matrix(3, 3, Float32)
matrix(4, 4, Float32)

alias Matrix2 = Matrix2x2
alias Matrix3 = Matrix3x3
alias Matrix4 = Matrix4x4
