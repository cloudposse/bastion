# Bastion example using docker-compose 

This example starts up cloudposse bastion, github-authorized-keys and etcd.  

### Requirements
1. You will need to [install docker-compose](https://docs.docker.com/compose/install/).  
2. Have an [SSH key added to your github account](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account).
##### Recommended
Create a slack webhook. Follow this simple [guide](https://api.slack.com/tutorials/slack-apps-hello-world).  
Copy `bastion.env.example` to `bastion.env` and set the following variable;  
```
SLACK_WEBHOOK_URL=<slack_webhook_url>
```

Obtain the GitHub API Token (aka Personal Access Token) [here](https://github.com/settings/tokens). Click "Generate new token" and select `read:org`.  
Create a team [here](https://help.github.com/en/articles/creating-a-team).  
Copy `gak.env.example` to `gak.env` and set the following variables;
```
GITHUB_API_TOKEN=<your_token>
GITHUB_ORGANIZATION=<your_organization>
GITHUB_TEAM=<your_team>
```
### Start the stack
To start, run  
```
bastion/examples/compose$ docker-compose up -d
```

### Connect to bastion
Connect to bastion via ssh by running.  
```
bastion/examples/compose$ ssh <github_user_name>@<docker_ip> -p 1234
```
<docker-ip> may be one of the following;
1. localhost
2. `bastion/examples/compose$ docker-machine ip`

Make sure you substitute the appropriate values.

### Check status
Check the status of your containers by running;
```
bastion/examples/compose$ docker-compose ps
```
Your output should look like this
```sh
      Name                     Command               State                                               Ports
-----------------------------------------------------------------------------------------------------------------------------------------------------------
compose_bastion_1   /init                            Up      0.0.0.0:1234->22/tcp
compose_etcd_1      /etcd --advertise-client-u ...   Up      0.0.0.0:2379->2379/tcp, 0.0.0.0:2380->2380/tcp, 0.0.0.0:4001->4001/tcp, 0.0.0.0:7001->7001/tcp
compose_gak_1       github-authorized-keys           Up      0.0.0.0:301->301/tcp

```

### Clean up
To stop the containers and remove attached volumes, run;
```
bastion/examples/compose$ docker-compose down -v
```

### Build from source
To stop the containers and remove attached volumes, run;
```
bastion/examples/compose$ docker-compose down -v
```

## References
https://github.com/cloudposse/github-authorized-keys


## References
https://github.com/cloudposse/github-authorized-keys  
https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account  
https://api.slack.com/tutorials/slack-apps-hello-world  
https://help.github.com/en/articles/creating-a-team  