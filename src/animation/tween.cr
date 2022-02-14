
enum TweenMode
    None
    Linear
    Sigmoid
    EaseIn
    EaseOut
    EaseInOut
end

macro tween(value, target, t, mode, mode_options = {} of Symbol => (Float32 | String))
    {% case mode %}
    {% when TweenMode.Linear %}
    {% end %}
end