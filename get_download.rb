require 'pathname'
require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'optparse'
require 'io/console'

hostname = 'alkaid.thilp.net'
username = 'roucool'
extension = %w(*.mp4 *.mkv *.avi)
terminal_width = IO.console.winsize[1]

OptionParser.new { |opts|
  opts.banner = 'Usage: get_download.rb [options]'
  opts.on('-e', '--disable-extension-check', 'Disables extension check for files') do
    extension = []
  end
}.parse!
extension = extension.map{|e| "-name '#{e}' -o "}.join
cmd = "find /srv/deluge/ #{extension.strip.chomp('-o')}| grep -Ei '#{ARGV * '|'}'"

puts 'Connecting to remote host ' + hostname
STDOUT.flush
Net::SSH.start(hostname, username) do |ssh|
  puts 'Connected'
  STDOUT.flush
  res = ssh.exec!(cmd)
  res.each_line do |file|
    ssh.scp.download! file.chomp, 'D:/Users/vincen_p/Videos' do |ch, name, sent, total|
      progress = 100 * sent / total
      print "#{name}:" + ' ' * terminal_width - name.length - 50 +'[' + ('=' * (progress / 2)) + (' ' * (50 - (progress / 2))) + "] #{progress}%\r"
      STDOUT.flush
    end
    p
  end
  ssh.close
end
