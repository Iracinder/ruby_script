require 'io/console'
require 'terminal-size'

class Loading_bar
  def initialize(name, longest=nil, bar_size=50)
    @name = name
    @offset = nil
    @start = Time.now
    unless longest.nil?
      @offset = longest - name.length
    end
    @bar_size = bar_size
  end

  def progress(sent, total)
    progress = 100 * sent / total
    buffer = ' ' * (Terminal.size[:width] - 10 - @name.length - @bar_size)
    bar = '[' + ('=' * (progress / 2)) + (' ' * (@bar_size - (progress / 2))) + "] #{progress.to_s.rjust(4)}%"
    unless  @offset.nil?
      buffer = ' ' * @offset
    end
    "#{@name}: #{buffer} #{bar} ETA #{eta progress}"
  end

  def eta(progress)
    time_spent = Time.now - @start
    time_end = 100 * time_spent / progress
    time_left = Time.at(time_end - time_spent)
    "#{time_left.min.to_s.rjust(2, '0')}:#{time_left.sec.to_s.rjust(2, '0')}"
  end


end
