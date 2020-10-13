macro any_option
  Number | Range(Number, Number) | String
end

abstract class Producer(T)
  def numeric_limits
    {
      "Int32"   => (Int32::MIN..Int32::MAX),
      "Int64"   => (Int64::MIN..Int64::MAX),
      "Float32" => (Float32::MIN / 2.0..Float32::MAX / 2.0),
      "Float64" => (Float64::MIN / 2.0..Float64::MAX / 2.0),
    }
  end

  abstract def produce(trial_num : Int32, options : Hash(Symbol, String)) : T
end

macro number_producer(number_type)
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

number_producer(Int32)
number_producer(Int64)
number_producer(Float32)
number_producer(Float64)

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

# Defines a property of an object/function under test
#
# `prop my_property_name_with_underscores, some_expression > 10, some_expression : TypeOfParameter`
macro prop(name, expression, *args)
  {% prop_name = "prop_#{name}".id %}
  {% arg_types = args.select { |a| a.class_name == "TypeDeclaration" } %}
  {% options = args.select { |a| a.class_name == "NamedTupleLiteral" }.map(&.double_splat) %}
  {% options_hash = options.empty? ? "{} of String => String" : options %}

  {% if env("QUICKCHECK") %}

    # Run examples for generated input
  {{prop_name}} = ->(num_inputs : Int32) {

    # put the predicate under test in a function
    example = ->({{ *arg_types }}) {
      {{expression}}
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

    (0..num_inputs).each do |trial_num|
      {% if arg_types.empty? %}
      result = {return_val: example.call()}
      {% else %}
      trial_args = Tuple({{arg_types.map { |t| t.type }.splat}}).from(arg_template.map(&.produce(trial_num, {{options_hash}})))
      result = {return_val: example.call(*trial_args)}
      {% end %}

      it "#{trial_num}: should exhibit property {{name}} with args #{trial_args}" do
        result[:return_val].should be_true
      end
    end
  }

  {{prop_name}}.call(50)

  {% end %}
end
