require 'io/console'
require 'terminal-size'


class Loading_bar
  attr_reader :name
  attr_reader :start
  attr_reader :bar_size
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
    progress = 100 * sent.to_f / total
    buffer = ' ' * (Terminal.size[:width] - 10 - @name.length - @bar_size)
    bar = '[' + ('=' * (progress / 2)) + (' ' * (@bar_size - (progress / 2))) + "] #{progress.to_i.to_s.rjust(4)}%"
    unless  @offset.nil?
      buffer = ' ' * @offset
    end
    "#{@name}: #{buffer} #{bar} ETA #{eta progress}"
  end

  def eta(progress)
    if progress == 0
      return '-:-'
    end
    time_spent = Time.now - @start
    time_end = 100 * time_spent / progress
    time_left = Time.at(time_end - time_spent)
    "#{time_left.min.to_s.rjust(2, '0')}:#{time_left.sec.to_s.rjust(2, '0')}"
  end
end
