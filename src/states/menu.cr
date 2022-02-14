require "./game_state"

class Menu < GameState
    def initialize()
        super
    end

    def update(elapsed : SF::Time, input : InputState) : Schedule
        Schedule::Next
    end
end