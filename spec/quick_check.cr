macro any_option
  Number | Range(Number, Number) | String
end

abstract class Producer(T)
  def numeric_limits
    {
      "Int32" => (Int32::MIN..Int32::MAX),
      "Int64" => (Int64::MIN..Int64::MAX),
      "Float32" => (Float32::MIN / 2.0..Float32::MAX / 2.0),
      "Float64" => (Float64::MIN / 2.0..Float64::MAX / 2.0)
    }
  end

  abstract def produce(trial_num : Int32) : T
end

macro number_producer(number_type)
  class {{number_type}}Producer < Producer({{number_type}})
    def produce(trial_num, options)
      if options[:range].is_a?(Range({{number_type}}, {{number_type}}))
        Random.new.rand(options[:range])
      else
        Random.new.rand(numeric_limits[{{number_type.to_s}}])
      end
    end
  end
end

number_producer(Int32)
number_producer(Int64)
number_producer(Float32)
number_producer(Float64)

class StringProducer < Producer(String)
  def produce(trial_num, options)
    length = if options[:length].is_a?(Int32)
      options[:length].as(Int32)
    else
      Random.new.rand((0..500))
    end
    String.new(Random.new.random_bytes(length))
  end
end

macro prop(name, expression, *args)
  {% prop_name = "prop_#{name}".id %}
  {% arg_types = args.select {|a| a.class_name == "TypeDeclaration"} %}
  {% options = args.select {|a| a.class_name == "NamedTupleLiteral"}.map(&.double_splat) %}
  
    # Run examples for generated input
  {{prop_name}} = ->(num_inputs : Int32) {
    {% if true or env("QUICKCHECK") %}

    example = ->({{ *arg_types }}) {
      {{expression}}
    }

    # Generate test cases for each argument
    arg_template = [
      {% for arg in arg_types %}
      {% if arg.type %}
      {{arg.type}}Producer.new,
      {% end %}
    ]
    for trial_num in (0..num_inputs)
      trial_args = arg_template.map(&.produce(trial_num, {{options}}))
      begin
        result = {return_val: example(trial_args}
      rescue
        result = {return_val: false}
      end

      puts result
      it "#{trial_num}: should exhibit property {{name}} with args #{trial_args}" do 
        result.return_val.should be_true
      end
    end

    {% end %}
  }

  {{prop_name}}.call()
end