require 'json'
require 'fileutils'
require 'mixlib/shellout'

# Helpers module for stuff that is always needed
module Helpers
  extend self

  @@config = {}

  def environment
    config['docker_environment'].map { |k, v| "--env #{k}=#{v}"}.join(' ')
  end

  # Get the project configuration. Merge the defaults with the user specific config
  #
  # @return [Hash] Config hash
  #
  def config
    return @@config unless @@config.empty?

    config_path = File.expand_path('..', File.dirname(__FILE__))
    default_config = JSON.parse(File.read("#{config_path}/config.default.json"))
    user_config = if File.exist?("#{config_path}/config.json")
                    JSON.parse(File.read("#{config_path}/config.json"))
                  else
                    {}
                  end

    @@config = default_config.merge(user_config)
  end

  # Simple info logger using the log helper
  #
  # @param info [String] The info string to log to STDOUT
  #
  def info_log(info)
    log(stdout: "\e[43m\e[30m  #{info}\e[0m", stderr: '', cmd: '', return: 0)
  end

  # Log helper
  #
  # @param out [Hash] Output hash of run_command
  #
  # @return [Integer] The return code of run_command
  #
  def log(out, error_msg = '')
    if out[:return].nil? || out[:return] == 0
      puts out[:stdout] unless out[:stdout].nil? || out[:stdout].empty?
    else
      puts "--- Failed with exit code #{out[:return]}"
      puts "Command was: #{out[:cmd]}"
      unless out[:stdout].empty?
        puts "--- STDOUT:"
        puts out[:stdout].strip
      end
      unless out[:stderr].empty?
        puts "--- STDERR:"
        puts out[:stderr].strip
      end

      raise error_msg
    end

    return out[:return]
  end

  # Should we go to debug mode?
  #
  def debug?
    (!ENV['DEBUG'].nil? && !ENV['DEBUG'].empty?)
  end

  # Run system command
  #
  # @param cmd [String] The system <cmd> to run
  #
  # @param opts [Hash] The option hash to pass to Mixlib::ShellOut
  #
  # @return [Hash] The return code and stdout of the command
  #
  def run_command(cmd, opts = {})
    out = { stdout: '', stderr: '', return: '' }

    options = opts.merge(timeout: 6000)
    options = options.merge(live_stream: STDOUT) if debug?

    Bundler.with_clean_env do
      commander = ::Mixlib::ShellOut.new(cmd, options)
      commander.run_command
      # commander.error!

      out[:cmd] = cmd
      out[:return] = commander.exitstatus
      out[:stdout] = commander.stdout unless debug?
      out[:stderr] = commander.stderr unless debug?
    end

    return out
  end
end
