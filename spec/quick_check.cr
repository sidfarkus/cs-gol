

abstract class Producer(T)
  def numeric_limits
    {
      "Int32"   => (Int32::MIN..Int32::MAX),
      "Int64"   => (Int64::MIN..Int64::MAX),
      "Float32" => (Float32::MIN..Float32::MAX),
      "Float64" => (Float64::MIN..Float64::MAX),
    }
  end

  abstract def produce(trial_num : Int32, options : Hash(Symbol, String)) : T
end

macro integer_producer(number_type)
  {% type_str = number_type.resolve.name %}
  class {{type_str}}Producer < Producer({{type_str}})
    def produce(trial_num, options) : {{type_str}}
      if options[:range].is_a?(Range({{type_str}}, {{type_str}}))
        Random.new.rand(options[:range])
      else
        Random.new.rand(numeric_limits[{{type_str.stringify}}])
      end
    end
  end
end

integer_producer(Int32)
integer_producer(Int64)

macro float_producer(number_type)
  {% type_str = number_type.resolve.name %}
  {% conversion = "to_f#{type_str[-2..-1]}".id %}
  class {{type_str}}Producer < Producer({{type_str}})
    def produce(trial_num, options) : {{type_str}}
      # Use method from Haskell's quickcheck to generate a random rational and offset for our final float
      random = Random.new
      ratio = random.next_int.{{conversion}} / (random.next_int.abs + 1).{{conversion}}
      ratio + random.rand(5 ** {{type_str}}::DIGITS).to_f32
    end
  end
end

float_producer(Float32)
float_producer(Float64)

class StringProducer < Producer(String)
  def produce(trial_num, options) : String
    length = if options[:length].is_a?(Int32)
               options[:length].as(Int32)
             else
               Random.new.rand((0..500))
             end
    String.new(Random.new.random_bytes(length))
  end
end

# Defines a property of an object/function under test.
#
# ```
# prop my_property_name_with_underscores, a : MyType do |a|
#   a.method == 5
# end
# ```
macro prop(name, *args, &block)
  {% pretty_name = name.id.stringify.tr("_", " ").id %}
  {% prop_name = "prop_#{name.id}".id %}
  {% arg_types = args.select { |a| a.is_a?(TypeDeclaration) } %}
  {% options = args.select { |a| a.is_a?(NamedTupleLiteral) }.map(&.double_splat) %}
  {% options_hash = options.empty? ? "{} of Symbol => String".id : options %}

  {% if env("QUICKCHECK") %}

  {% if block.args.size > arg_types.size %}
  {% raise "Error instantiating property '#{pretty_name}' -- cannot populate #{block.args.size} argument(s) for test with arguments of type " + arg_types.stringify %}
  {% end %}

  # Run examples for generated input
  {{prop_name}} = ->(num_inputs : Int32) {

    # put the predicate under test in a function
    example = ->({{ *arg_types }}) {
      {{block.body}}
    }

    # Generate test cases for each argument
    arg_template =
    {% if arg_types.empty? %}
    [] of Producer(Int32)
    {% else %}
    [
      {% for arg in arg_types %}
      {% if arg.type %}
      {{arg.type}}Producer.new,
      {% end %}
      {% end %}
    ]
    {% end %}

    it "should exhibit property {{pretty_name}}" do
      (0..num_inputs).each do |trial_num|
        {% if arg_types.empty? %}
        result = {return_val: example.call()}
        {% else %}
        trial_args = Tuple({{arg_types.map { |t| t.type }.splat}}).from(arg_template.map(&.produce(trial_num, {{options_hash}})))
        result = {return_val: example.call(*trial_args)}
        {% end %}

        if result[:return_val].is_a?(Bool)
          result[:return_val].should be_true, "property {{pretty_name}} was not valid for arguments #{trial_args}"
        end
      end
    end
  }

  {{prop_name}}.call(50)
  {% else %}
  pending "property {{pretty_name}} is disabled"
  {% end %}
end
