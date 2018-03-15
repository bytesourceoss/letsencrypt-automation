require 'date'
sh '/bin/bash lib/init.sh' if !File.exist?('Gemfile.lock') || (Date.today - File.mtime('Gemfile.lock').to_date).to_i > 20

require 'bundler/setup'
require_relative 'lib/helpers'
require_relative 'lib/git'
require_relative 'lib/certbot'
require_relative 'lib/chef_vault'

Rake.application.options.suppress_backtrace_pattern = %r{/} # Suppress trace when running. Using --trace still works

desc 'Initialize project'
task :init do
  Helpers.log Certbot.init
  Helpers.log ChefVault.init if Helpers.config['steps'].include?('chef_vault')
  # HashicorpVault.init if Helpers.config['steps'].key?('hashicorp_vault')
end

desc 'Displays Help'
task :help do
  puts 'How to use these rake taks:
Check the available tasks with rake23 -T.'
end

namespace :git do
  desc 'Commit and push repository'
  task :push do
    Git.push
  end
end

namespace :certbot do
  desc 'Register Certbot account'
  task :register do
    Helpers.log Certbot.register
  end

  desc 'Run arbitrary certbot command passed as parameter'
  task :run, [:cmd] do |_t, args|
    Helpers.log Certbot.run(args[:cmd])
  end

  desc 'Run certbot to obtain or renew certificates'
  task :renew do
    Helpers.config['certificates'].each do |name, props|
      Helpers.log Certbot.renew(name, props['domains'])
    end
  end

  desc 'Run certbot to revoke a certificate'
  task :revoke, [:cert] do |_t, args|
    Helpers.log Certbot.revoke(args[:cert])
  end
end

namespace :chef_vault do
  desc 'Upload all changed certificates as chef vaults'
  task :upload do
    Helpers.config['certificates'].each do |name, props|
      Helpers.log ChefVault.upload(name, props['chef_vault'] || {})
    end
  end
end if Helpers.config['steps'].include?('chef_vault')

desc 'Cleanup all temporary files, docker containers etc'
task :cleanup do
  Helpers.log Certbot.cleanup
  Helpers.log ChefVault.cleanup if Helpers.config['steps'].include?('chef_vault')
end
