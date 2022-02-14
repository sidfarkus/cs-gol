require "./game_state"
require "./menu"

class Title < GameState

    def initialize(@render : SF::RenderWindow)
        super()
        @text = SF::Text.new("the game of life", FONT, 42)
        @text.position = {90, 70}
        @text.color = SF::Color::Black
    end

    def update(elapsed : SF::Time, input : InputState) : Schedule
        @render.draw @text
        swap_with(Menu.new) if input.action_on?(:activate)

        Schedule::Next
    end

end