require 'json'

# Chef Vault module
module ChefVault
  extend self

  def init
    options = [ "-itd #{Helpers.environment}",
                "--name #{Helpers.config['chef_vault']['docker_container']}",
                "-v `pwd`/etc_letsencrypt:/etc/letsencrypt",
                "-v #{Helpers.config['chef_vault']['config_dir']}:/root/.chef"
    ]

    Helpers.run_command("docker run #{options.join(' ')}  #{Helpers.config['chef_vault']['docker_image']}")
  end

  def cleanup
    Helpers.run_command("docker rm -f #{Helpers.config['chef_vault']['docker_container']}")
  end

  # Upload all certificates to the chef server
  def upload(cert, props = {})
    Helpers.info_log("Uploading Chef Vault for #{cert}")
    options = [ '--mode client' ]
    options << "--admins #{Helpers.config['chef_vault']['admins'].join(',')}" if Helpers.config['chef_vault'].key?('admins')
    options << "--clients #{props['clients'].join(',')}" if props.key?('clients')
    options << "--search #{props['search']}" if props.key?('search')

    current_item = run("vault itemtype #{Helpers.config['chef_vault']['data_bag']} #{cert}")
    if current_item[:return] == 0 && current_item[:stdout].include?('vault')
      run("vault update --clean #{options.join(' ')} #{Helpers.config['chef_vault']['data_bag']} #{cert} '#{vault_json(cert)}'")
    elsif current_item[:return] == 0 && !current_item[:stdout].include?('vault')
      { return: 1, stdout: "The DataBag item #{Helpers.config['chef_vault']['data_bag']}/#{cert} is not of type vault. Please delete the item first.", stderr: ''}
    elsif current_item[:return] == 100 && current_item[:stderr].include?('ERROR: The object you are looking for could not be found')
      run("vault create #{options.join(' ')} #{Helpers.config['chef_vault']['data_bag']} #{cert} '#{vault_json(cert)}'")
    else
      current_item
    end
  end

  def run(cmd)
    Helpers.run_command("docker exec -i #{Helpers.config['chef_vault']['docker_container']} knife #{cmd}")
  end

  def vault_json(cert)
    vault = {}
    %w(cert chain fullchain privkey).each do |file|
      vault[file] = File.read("etc_letsencrypt/live/#{cert}/#{file}.pem")
    end

    vault.to_json
  end
end
