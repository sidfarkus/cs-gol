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
      self.new([
        {% for row in 0...rows %}
        {% for col in 0...cols %}
        {{kind}}.new(0),
        {% end %}
        {% end %}
      ])
    end

    def self.identity
      self.new([
        {% for row in 0...rows %}
        {% for col in 0...cols %}
        {% if row == col %}
        {{kind}}.new(1),
        {% else %}
        {{kind}}.new(0),
        {% end %}
        {% end %}
        {% end %}
      ])
    end

    def initialize(data : Array({{kind}}))
      if data.size != {{rows * cols}}
        raise Exception.new("Array data must match rank {{rows}} by {{cols}}!")
      end
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

    def []=(row, col, val : {{kind}})
      @data[row * {{cols}} + col] = val
    end

    def rows
      [
      {% for row in 0...rows %}[
      {% for col in 0...cols %}
      @data[{{row * cols + col}}],
      {% end %}],
      {% end %}
      ]
    end

    def each_row
      @data.each_slice({{cols}})
    end

    def cols
      [
      {% for col in 0...cols %}[
      {% for row in 0...rows %}
      @data[{{row * cols + col}}],
      {% end %}],
      {% end %}
      ]
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

    def *(other : Matrix{{cols}}x{{rows}})
      raise Exception.new if other.col_count != row_count
      output = Matrix{{rows}}x{{rows}}.zeros
      {% for row in 0...rows %}
      {% for col in 0...rows %}
      output[{{row}}, {{col}}] = rows[{{row}}].zip(other.cols[{{col}}]).map {|a, b| a * b }.sum
      {% end %}
      {% end %}
      output
    end

    {% if rows == 3 && cols == 3 %}
    def *(other : Vector({{kind}}))
      Vector({{kind}}).new(
        {% for row in 0...rows %}
        @data[{{row * cols}}] * other.x + @data[{{row * cols + 1}}] * other.y + @data[{{row * cols + 1}}] * other.z,
        {% end %}
      )
    end
    {% end %}

    def ==(other)
      return false if other.col_count != col_count || other.row_count != row_count
      return @data == other.data
    end

    def to_s
      "{{rows}}x{{cols}} {% for row in 0...rows %}[{% for col in 0...cols %}#{self[{{row}},{{col}}]}{% if col != cols - 1 %}, {% end %}{% end %}]\n{% end %}"
    end

    def to_s(io)
      io << to_s
    end

    def inspect(io : IO)
      to_s(io)
    end
  end
end
