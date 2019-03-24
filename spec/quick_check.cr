abstract class Prop
  property name, arg_types

  @@props = Hash(Symbol, Prop)

  def initialize(@name : Symbol,
                 @arg_types : Tuple(Value.class | Reference.class),
                 @options : NamedTuple(Symbol, String))
  end

  def self.props
    @@props
  end

  def self.add(prop)
    @@props[prop.name] = prop
  end

  abstract def example(*args, **kwargs)
end

macro prop(name, expression, *args)
  class Prop_{{name}} < Prop
    def initialize()
      super(name: :{{name}},
            arg_types: {{ args.select {|a| a.class_name == "TypeDeclaration"}.map(&.type) }},
            {% if args.select {|a| a.class_name == "NamedTupleLiteral"}.size > 0 %}
              options: {{ args.select {|a| a.class_name == "NamedTupleLiteral"}.map(&.double_splat) }}
            {% end %})
      Prop.add self
    end

    # Run examples for generated input
    def test(num_inputs = 100)
      {% if true or env("QUICKCHECK") %}

      # Generate test cases for each argument
      {% for arg in (0..args.size) %}
        {% for other in (0..args.size) %}
          {% if arg != other %}
          begin
            test_args = []
            test_result = example(*test_args)
          rescue e
            test_result = e
          end

          {% end %}
        {% end %}
      {% end %}

      {% end %}
    end

    def example({{ *args.select {|a| a.class_name == "TypeDeclaration"} }})
      {{expression}}
    end
  end

  Prop_{{name}}.new
end

prop foo, x > 10, x : Int32