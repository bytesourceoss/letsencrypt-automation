# Letsencrypt automation wrapper

## Using it

Clone this repository and change the origin to an internal private git repo of your choice. This repo will in the end contain the certificates you register. Make sure adequate permissions are set up!

### Requirements

To run this you need at least:

  * Git
  * Docker
  * Ruby (>= 2) and Bundler

You also have to initialize the Chef Data Bag used for the certificates. By default that is called `letsencrypt` via `knife data bag create letsencrypt`.

### Config

Create a file called `config.json` alongside the `config.default.json` and fill in the changes you want. An example of all available config settings is given here:

```
{
  "docker_environment": {
    "https_proxy": "http://proxy.service.com:5678",
    "http_proxy": "http://proxy.service.com:5678",
    "no_proxy": ".service.com"
  },
  "certbot": {
    "docker_image": "docker.local/certbot/dns-route53:v0.22.0",
    "docker_container": "certbot",
    "aws_credentials": "~/.aws/credentials",
    "email": "my.email@domain.net",
    "server": "https://acme-staging-v02.api.letsencrypt.org/directory"
  },
  "chef": {
    "docker_image": "docker.local/chef/chefdk:v2",
    "data_bag": "letsencrypt",
    "config_dir": "~/.chef",
    "admins": ["admin1", "admin2"]
  },
  "steps": [
    "chef_vault"
  ],
  "certificates": {
    "_star_.my.domain.com": {
      "domains": ["*.my.domain.com", "my.domain.com"],
      "chef_vault": {
        "clients": ["client1", "client2"],
        "search": "search term"
      }
    },
    "sometest.domain.com": {
      "domains": ["sometest.domain.com", "some-test.domain.com"],
      "hashicorp_vault": {
        "permissions_to_set": "a"
      }
    }
  }
}
```

The two public ACME Servers are:

  * https://acme-staging-v02.api.letsencrypt.org/directory
  * https://acme-v02.api.letsencrypt.org/directory

### Run manually

To run the tasks manually check out the available rake tasks with `rake -T`. To initialize the project you have to register an account at LetsEncrypt once. To do so run:

```
rake init
rake certbot:register
```

once and commit the changes. With the account registered and the Chef Data Bag create the usual workflow is to update the `config.json` with the certificates that should be created and then to run:

```
rake init
rake certbot:renew
rake chef_vault:upload
rake cleanup
```

### Running in Jenkins

There is a Jenkinsfile available in this repo which should do everything for you once you are set up.

## Updating

Add this repo as a remote

```
git remote add update https://github.com/bytesourceoss/letsencrypt-automation.git
```

And fetch the changes you want

```
git fetch update master # Fetch changes from master
git fetch update refs/tags/1.0.0 # Fetch a specific tag
```

# ToDo

Pretty much everything I guess...

  * How to upload only changed certificates
    * Read state from git?
    * Keep state file with changes?
  * Change Rake tasks to be able to take a list of certificates as argument
  * Add Chef Vault refresh rake task
