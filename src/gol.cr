require "crsfml"

require "./*"
require "./rendering/*"
require "./geometry/*"

FONT = SF::Font.from_file("#{__DIR__}/../resources/OpenSauceOne-Medium.otf")

window = SF::RenderWindow.new(
  SF::VideoMode.new(1680, 1050), "Game of Life",
  SF::Style::Titlebar | SF::Style::Close
)
window.vertical_sync_enabled = true
text = SF::Text.new("the game of life", FONT, 42)
text.position = {90, 70}
text.color = SF::Color::Black

clock = SF::Clock.new
while window.open?
  while event = window.poll_event
    case event
    when SF::Event::Closed
      window.close
    end
  end

  window.clear SF::Color::White

  window.draw text

  window.display
end
