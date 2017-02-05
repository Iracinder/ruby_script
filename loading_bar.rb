require 'io/console'
require 'terminal-size'


class Loading_bar
  def initialize(name, longest=nil, bar_size=50)
    @name = name
    @offset = longest - name.length
    @bar_size = bar_size
  end

  def progress(sent, total)
    progress = 100 * sent / total
    buffer = ' ' * (Terminal.size[:width] - 10 - @name.length - @bar_size)
    bar = '[' + ('=' * (progress / 2)) + (' ' * (@bar_size - (progress / 2))) + "] #{progress}%"
    unless  @offset.nil?
      buffer = ' ' * @offset
    end
    "#{@name}: #{buffer} #{bar}\r"
  end
end
