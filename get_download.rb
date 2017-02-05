require 'pathname'
require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'optparse'
require 'io/console'
require_relative 'loading_bar'

hostname = 'alkaid.thilp.net'
username = 'roucool'
extension = %w(*.mp4 *.mkv *.avi)

def longest(source)
  arr = source.split
  arr.sort! { |a, b| b.length <=> a.length }
  arr[0].length
end

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
  longest_name = longest res
  res.each_line do |file|
    bar = Loading_bar.new file.chomp, longest_name
    ssh.scp.download! file.chomp, 'D:/Users/vincen_p/Videos' do |ch, name, sent, total|
      print bar.progress sent, total
      STDOUT.flush
    end
    p
  end
  ssh.close
end
