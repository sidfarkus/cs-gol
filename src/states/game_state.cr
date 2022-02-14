require "crsfml"
require "../geometry/vector"

abstract class GameState

    enum BindingState
        Inactive
        Starting
        Active
        Stopping
    end

    class Binding
        getter input, action
        property state

        def initialize(@input : SF::Keyboard::Key | SF::Mouse::Button, @action : Symbol)
            @state = BindingState::Inactive
        end
    end

    struct InputState
        getter bindings
        @bindings : Hash(Symbol, Binding)

        def initialize(bindings : Enumerable(Binding))
            @bindings = bindings.to_h {|b| {b.action, b} }
        end

        def action_state(action : Symbol) : BindingState | Nil
            binding = @bindings[action]?
            binding.state unless binding.nil?
        end

        def action_on?(action : Symbol) : Bool
            action_state(action) != BindingState::Inactive
        end

        def mouse_position() : Vector(Int32)
            position = SF::Mouse.position
            Vector(Int32).new(position.x, position.y, 0)
        end

        def update_bindings()
            @bindings.each do |_, action|
                button_down = case action.input
                in SF::Keyboard::Key
                    SF::Keyboard.key_pressed?(action.input.as(SF::Keyboard::Key))
                in SF::Mouse::Button
                    SF::Mouse.button_pressed?(action.input.as(SF::Mouse::Button))
                end

                if button_down
                    case action.state
                    when BindingState::Inactive
                        action.state = BindingState::Starting
                    when BindingState::Starting
                        action.state = BindingState::Active
                    when BindingState::Active
                        # do nothing
                    when BindingState::Stopping
                        action.state = BindingState::Active
                    end
                else
                    case action.state
                    when BindingState::Inactive
                        # do nothing
                    when BindingState::Starting
                        action.state = BindingState::Inactive
                    when BindingState::Active
                        action.state = BindingState::Stopping
                    when BindingState::Stopping
                        action.state = BindingState::Inactive
                    end
                end
            end
        end
    end

    struct Schedule
        getter next_time : SF::Time

        def initialize(@next_time : SF::Time)
        end

        Next = Schedule.new(SF::Time::Zero)
    end

    enum State
        Disconnected
        StartPush
        StartPop
        Inactive
        Active
    end

    getter state
    property time_left
    property pushed_state : GameState | Nil

    def initialize()
        @state = State::Inactive
        @time_left = SF.seconds(0)
    end

    def schedule_pop()
        @state = State::StartPop
    end

    def swap_with(state : GameState)
        push_state(state)
        schedule_pop
    end

    def push_state(state : GameState)
        raise Exception.new("Cannot push more than one state from a single update!") unless @pushed_state.nil?
        @pushed_state = state
    end

    def transition(toState : State) : Void
        # Nothing needed here unless overridden
    end

    abstract def update(elapsed : SF::Time, input : InputState) : Schedule

    # update states that should be scheduled and advance time
    # this method modifies the states array
    def self.update_states(states : Array(GameState), elapsed : SF::Time, input : InputState)
        states.each do |state|
            time_left = state.time_left
            time_left -= elapsed
            if time_left <= SF.seconds(0)
                scheduled = state.update(elapsed, input)
                state.time_left = scheduled.next_time
            end
        end

        last_state = states.last
        if last_state.state == GameState::State::StartPop
            states[-2].transition(GameState::State::Active) if states.size > 1
            states.pop().transition(GameState::State::Disconnected)
        end

        if last_state.pushed_state != nil
            new_state = last_state.pushed_state.not_nil!
            last_state.pushed_state = nil

            new_state.transition(GameState::State::StartPush)
            last_state.transition(GameState::State::Inactive) if last_state.state != GameState::State::Disconnected
            states.push(new_state)
            new_state.transition(GameState::State::Active)
        end

        states
    end
end