require 'pathname'
require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'optparse'
require 'io/console'
require_relative 'loading_bar'


def parse_cmd_line
  options = {}
  options['config'] = '.env'
  ext = %w(*.mp4 *.mkv *.avi)
  options['extension'] = ext.map{|e| "-name '#{e}' -o "}.join
  OptionParser.new { |opts|
    opts.banner = 'Usage: get_download.rb [options]'
    opts.on('-e', '--disable-extension-check', 'Disables extension check for files') do
      options['extension'] = []
    end
    opts.on('-p', '--path PATH', 'Destination folder') do |p|
      options['path'] = p
    end
    opts.on('-s', '--server-path PATH', 'path to deluge files') do |p|
      options['server_path'] = p
    end
    opts.on('-c', '--config FILE', 'Allow to add config file') do |conf|
      options['config'] = conf
    end
  }.parse!
  options
end

def load_env config_file
  env = {}
  begin
    File.open(config_file, 'r') do |f|
      f.each_line do |line|
        env[line.split('=')[0].strip] = line.split('=')[-1].strip
      end
    end
  rescue SystemCallError
    $stderr.print "No config file found\n"
  end
  env
end

options = parse_cmd_line
env = load_env options['config']
cmd = "find #{env['server_path']} #{options['extension'].strip.chomp('-o')}| grep -Ei '#{ARGV * '|'}'"
puts 'Connecting to remote host ' + env['hostname'].to_s
STDOUT.flush
Net::SSH.start(env['hostname'], env['username']) do |ssh|
  puts 'Connected'
  STDOUT.flush
  res = ssh.exec!(cmd)
  longest_name = res.split(/\n+/).max_by(&:length).length
  res.each_line do |file|
    bar = Loading_bar.new file.chomp, longest_name
    ssh.scp.download! file.chomp, env['path'] do |ch, name, sent, total|
      print "#{bar.progress sent, total}\r"
      STDOUT.flush
    end
    puts
  end
  ssh.close
end
