require 'etc'
require_relative 'helpers'

# Cerbot module
module Certbot
  extend self

  def init
    Helpers.run_command("docker run -itd #{Helpers.environment} --name #{Helpers.config['certbot']['docker_container']} -v `pwd`/etc_letsencrypt:/etc/letsencrypt -v #{Helpers.config['certbot']['aws_credentials']}:/root/.aws/credentials --entrypoint '/bin/sh' #{Helpers.config['certbot']['docker_image']}")
  end

  def cleanup
    Helpers.run_command("docker rm -f #{Helpers.config['certbot']['docker_container']}")
  end

  def register
    run("register --agree-tos -m #{Helpers.config['certbot']['email']}")
  end

  # Renew a certificate if necessary. Parameters are usually ready from the config file
  #
  # @param name [String] The name of the certificate
  #
  # @param domains [Array] The domains for this certificate
  #
  def renew(name, domains)
    Helpers.info_log("Registering/Renewing certificate #{name} for domains #{domains.join(',')}")
    run("certonly --non-interactive --dns-route53 --cert-name #{name} --domains #{domains.join(',')}")

    # Fix permissions for etc_letsencrypt so we can actually commit it to GIT
    user = Etc.getpwuid
    Helpers.run_command("docker exec -i #{Helpers.config['certbot']['docker_container']} chown -R #{user.uid}:#{user.gid} /etc/letsencrypt")
  end

  def run(cmd)
    Helpers.run_command("docker exec -i #{Helpers.config['certbot']['docker_container']} certbot --server #{Helpers.config['certbot']['server']} --debug #{cmd}")
  end
end
