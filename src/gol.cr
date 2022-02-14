require "crsfml"

require "./*"
require "./rendering/*"
require "./geometry/*"
require "./states/*"

FONT = SF::Font.from_file("#{__DIR__}/../resources/OpenSauceOne-Medium.otf")

window = SF::RenderWindow.new(
  SF::VideoMode.new(1680, 1050), "Game of Life",
  SF::Style::Titlebar | SF::Style::Close
)
window.vertical_sync_enabled = true

states = [] of GameState
clock = SF::Clock.new

states.push(Title.new(window))

# TODO: read bindings
input = GameState::InputState.new(
  [
    GameState::Binding.new(SF::Keyboard::Escape,      :quit),
    GameState::Binding.new(SF::Keyboard::Space,   :activate)
  ]
)

while window.open?
  while event = window.poll_event
    case event
    when SF::Event::Closed
      window.close
    end
  end

  input.update_bindings
  break if input.action_on?(:quit)

  elapsed = clock.restart

  window.clear SF::Color::White

  states = GameState.update_states(states, elapsed, input)
  break if states.empty?

  window.display
end
