# Secure Bastion with MFA [![Build Status](https://travis-ci.org/cloudposse/bastion.svg)](https://travis-ci.org/cloudposse/bastion)

This is a secure/locked-down bastion implemented as a Docker Container. It uses Alpine Linux as the base image and ships with support for Google Authenticator & DUO MFA support.

It was designed to be used on Kubernetes together with [GitHub Authorized Keys](https://github.com/cloudposse/github-authorized-keys) to provide secure remote access to production clusters.

[![Docker Stars](https://img.shields.io/docker/stars/cloudposse/bastion.svg)](https://hub.docker.com/r/cloudposse/bastion)
[![Docker Pulls](https://img.shields.io/docker/pulls/cloudposse/bastion.svg)](https://hub.docker.com/r/cloudposse/bastion)
[![GitHub Stars](https://img.shields.io/github/stars/cloudposse/bastion.svg)](https://github.com/cloudposse/bastion/stargazers) 
[![GitHub Issues](https://img.shields.io/github/issues/cloudposse/bastion.svg)](https://github.com/cloudposse/bastion/issues)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/cloudposse/bastion.svg)](http://isitmaintained.com/project/cloudposse/bastion "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/cloudposse/bastion.svg)](http://isitmaintained.com/project/cloudposse/bastion "Percentage of issues still open")
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](https://github.com/cloudposse/bastion/pulls)
[![License](https://img.shields.io/badge/license-APACHE%202.0%20-brightgreen.svg)](https://github.com/cloudposse/bastion/blob/master/LICENSE)

## Demo

### MFA Setup & Usage

Here's a demo of what a user experiences when setting up Google Authenticator for the first time.

![Demo 1](docs/demo.gif)

When using Duo as the MFA provider, this becomes even more magical because Duo supports automatic Push notifications to your mobile device.
Just approve the request on your mobile phone (e.g. with a thumb press on iOS) when prompted.

### Slack Notifications

Here's what it looks like when someone connects to the bastion if Slack notifications are enabled. 

![Demo 2](docs/slack.png)

We recommend using Slack notifications for self-reporting. 
* Any time a user accesses production systems, they should reply to the slack notification to justify their remote access. 
* A "buddy" should approve the login by adding a reaction (e.g. ✅). 
* If no one approves the login, it should trigger an *incident response* to track down the unauthorized access.

## Help

**Got a question?** 
File a GitHub [issue](https://github.com/cloudposse/bastion/issues), send us an [email](http://cloudposse.com/contact/) or reach out to us on [Gitter](https://gitter.im/cloudposse/).


## Quick Start

Here's how you can quickly demo the `bastion`. We assume you have `~/.ssh/authorized_keys` properly configured and your SSH key (e.g. `~/.ssh/id_rsa`) added to your SSH agent. 


```bash
$ docker run -it -p 1234:22 \
     -e MFA_PROVIDER=google-authenticator \
     -v ~/.ssh/authorized_keys:/root/.ssh/authorized_keys 
     cloudposse/bastion
```

Now, in another terminal you should be able to run:
```bash
$ ssh root@localhost -p 1234
```

The first time you connect, you'll be asked to setup your MFA device. Subsequently, each time you connect, you'll be prompted to enter your MFA token.


## Usage


### Running

Refer to the [Environment Variables](#environment-variables) section below to tune how the `bastion` operates.


```bash
$ docker run -p 1234:22 cloudposse/bastion:latest
```

### Building

```bash
$ git clone https://github.com/cloudposse/bastion.git
$ cd bastion
$ make docker:build
```


### Configuration

## Recommendations

* Do not allow `root` (or `sudo`) access to this container as doing so would allow remote users to manipulate audit-logs in `/var/log/sudo-io`
* Use the bastion as a "jump host" for accessing other internal systems rather than installing a lot of unnecessary stuff, which increases the overall attack surface.
* Sync the contents of `/var/log/sudo-io` to a remote, offsite location. If using S3, we recommend enabling bucket-versioning.
* Use [`github-authorized-keys](https://github.com/cloudposse/github-authorized-keys/) to automatically provision users; or use the [Helm chart](https://github.com/cloudposse/charts/tree/master/incubator/bastion).
* Bind-mount `/etc/passwd`, `/etc/shadow` and `/etc/group` into the container as *read-only*
* Bind-mount `/home` into container; the bastion does not manage authorized keys

#### Environment Variables

The following tables lists the most relevant environment variables of the `bastion` image and their default values.

##### Duo Settings

Duo is a enterprise MFA provider that is very affordable. Details here: https://duo.com/pricing


| ENV               |      Description                                    |  Default |
|-------------------|:----------------------------------------------------|:--------:|
| `MFA_PROVIDER`    |  Enable the Duo MFA provider                        | duo      |
| `DUO_IKEY`        |  Duo Integration Key                                |          |
| `DUO_SKEY`        |  Duo Secret Key                                     |          |
| `DUO_HOST`        |  Duo Host Endpoint                                  |          |
| `DUO_FAILMODE`    |  How to fail if Duo cannot be reached               | secure   |
| `DUO_AUTOPUSH`    |  Automatically send a push notification             | yes      |
| `DUO_PROMPTS`     |  How many times to prompt for MFA                   | 1        |


##### Google Authenticator Settings

Google Authenticator is a free & open source MFA solution. It's less secure than Duo because tokens are stored on the server under each user account.


| ENV               |      Description                                    |  Default              |
|-------------------|:----------------------------------------------------|:---------------------:|
| `MFA_PROVIDER`    |  Enable the Google Authenticator provider           | google-authenticator  |  


##### Enforcer Settings

The enforcer ensures certain conditions are satisfied. Currently, these options are supported.

| ENV                           |  Description                                                 |  Default |
|-------------------------------|:-------------------------------------------------------------|:--------:|
| `ENFORCER_ENABLED`            |  Enable general enforcement                                  | `true`   |
| `ENFORCER_CLEAN_HOME_ENABLED` |  Erase dot files in home directory before starting session   | `true`   |

##### Slack Notifications

The enforcer is able to send notifications to a slack channel anytime there is an SSH login.

| ENV                        |      Description                                    |  Default  |
|----------------------------|:----------------------------------------------------|:---------:|
| `SLACK_HOOK`               | Slack integration method (e.g. `pam`, `sshrc`)      | `sshrc`   |
| `SLACK_WEBHOOK_URL`        | Webhook URL                                         |           |
| `SLACK_USERNAME`           | Slack handle of bot (defaults to short-dns name)    |           |
| `SLACK_TIMEOUT`            | Request timeout                                     | `2`       |
| `SLACK_FATAL_ERRORS`       | Deny logins if slack notificaiton fails             | `true`    |


##### SSH Auditor

The SSH auditor uses [`sudosh`](https://github.com/cloudposse/sudosh/) to record entire SSH sessions (`stdin`, `stdout`, and `stderr`).


| ENV                   |      Description                                    |  Default     |
|-----------------------|:----------------------------------------------------|:------------:|
| `SSH_AUDIT_ENABLED`   |  Enable the SSH Audit facility                      | `true`       |

This will require that users login with the `/usr/bin/sudosh` shell.

Update user's default shell by running the command: `usermod -s /usr/bin/sudosh $username`. By default, `root` will automatically be updated to use `sudosh`.

Use the `sudoreplay` command to audit/replay sessions.


#### User Accounts & SSH Keys

The `bastion` does not attempt to manage user accounts. We suggest using [GitHub Authorized Keys](https://github.com/cloudposse/github-authorized-keys) to provision user accounts and SSH keys. We provide a [chart](https://github.com/cloudposse/charts/incubator/bastion.git) of how we recommend doing it.

### Extending

The `bastion` was written to be easily extensible.

You can extend the enforcement policies by adding shell scripts to `etc/enforce.d`. Any scripts that are `+x` (e.g. `chmod 755`) will be executed at runtime. 



## Contributing

#### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/bastion/issues) to report any bugs or file feature requests.

#### Developing

PRs are welcome. In general, we follow the "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

NOTE: Be sure to merge the latest from "upstream" before making a pull request!

## Change Log

View our closed [Pull Requests](https://github.com/cloudposse/bastion/pulls?q=is%3Apr+is%3Aclosed).


## Thanks

- [@neochrome](https://github.com/neochrome/docker-bastion), for providing a great basic bastion built on top of Alpine Linux
- [@aws](https://aws.amazon.com/blogs/security/how-to-record-ssh-sessions-established-through-a-bastion-host/), for providing detailed instructions on how to do SSH session logging.
- [@duo](https://duo.com/docs/duounix), for providing excellent documentation
- [@google](https://github.com/google/google-authenticator-libpam) for contributing Google Authenticator to the Open Source community

## License

Apache2 © [Cloud Posse, LLC](https://cloudposse.com)

## About


The `bastion` is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know at <hello@cloudposse.com>



We love Open Source Software! 

See [our other projects][community]
or [hire us][hire] to help build your next cloud-platform.

  [website]: http://cloudposse.com/
  [community]: https://github.com/cloudposse/
  [hire]: http://cloudposse.com/contact/
  
### Contributors

[![Erik Osterman](http://s.gravatar.com/avatar/88c480d4f73b813904e00a5695a454cb?s=144)](https://osterman.com/) 

[Erik Osterman](https://github.com/osterman) 

  
