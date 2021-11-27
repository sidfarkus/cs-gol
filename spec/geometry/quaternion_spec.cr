require "../spec_helper"

class QuaternionFProducer < Producer(QuaternionF)
    def produce(trial_num, options) : QuaternionF
        producer = Float32Producer.new
        quat = QuaternionF.new(
            producer.produce(trial_num, options),
            producer.produce(trial_num, options),
            producer.produce(trial_num, options),
            producer.produce(trial_num, options)
        )
        if options[:unit]?
            quat.norm!
        end
        quat
    end
end

describe "Quaternion" do
    prop(:multiply_by_identity_is_original, q : QuaternionF) {|q| q * QuaternionF.identity == q}
    prop(:multiply_by_inverse_is_identity, q : QuaternionF) {|q| (q * q.inverse).close?(QuaternionF.identity, 0.00001)}
    prop(:lerp_to_end_is_destination, q1 : QuaternionF, q2 : QuaternionF) {|q1, q2| q1.lerp(q2, 1.0f32).close?(q2, 0.0001) }
end