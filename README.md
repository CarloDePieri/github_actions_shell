A github action to create a reverse ssh connection between a github workflow and
a public server.

This can be handy to inspect and debug a failing workflow job.

## SETUP

A public host that acts as relay is needed, with `sshd` installed.

Generate a custom ssh key pair with `ssh-keygen github_actions`. Add the resulting
public key to the `authorized_keys` on the relay server.

Create a action secret called `RSSH_ENV` and paste the value of [env.template](./env.template);
fill in the values:

- `SSH_KEY`: The `github_action` private key;
- `SSH_RELAY_HOST`: The relay host PUBLIC ip / domain name;
- `SSH_RELAY_USER`: The user on the relay host;
- `SSH_RELAY_KEY`: A relay host public key (the first from `ssh-keyscan $SSH_RELAY_HOST`).

Finally, add to the workflow file:

```yaml
- name: Launch a reverse ssh connection.
  uses: CarloDePieri/github_actions_shell@v1
  with:
    rssh_env: ${{ secrets.RSSH_ENV }}
```

### Alternative setup

It's possible to split the env in multiple secrets. As before, create the ssh key
pair and save the public key on the server.

Create some github action secrets:

- `RSSH_SSH_KEY`: The `github_action` private key;
- `RSSH_RELAY_HOST`: The relay host PUBLIC ip / domain name;
- `RSSH_RELAY_USER`: The user on the relay host;
- `RSSH_RELAY_KEY`: A relay host public key (the first from `ssh-keyscan $SSH_RELAY_HOST`).

Then, in the action file:

```yaml
- name: Launch a reverse ssh connection.
  uses: CarloDePieri/github_actions_shell@v1
  with:
    rssh_split_env: true
    rssh_ssh_key: ${{ secrets.RSSH_SSH_KEY }}
    rssh_relay_host: ${{ secrets.RSSH_RELAY_HOST }}
    rssh_relay_user: ${{ secrets.RSSH_RELAY_USER }}
    rssh_relay_key: ${{ secrets.RSSH_RELAY_KEY }}
```

## USAGE

Launch the github action, manually or with the ci. The job will enter a loop, suggesting
to add something like this to `.ssh/config` on the relay server:

```config
Host reverse
    HostName localhost
    StrictHostKeyChecking no
    Port 10022
    RequestTTY force
    RemoteCommand /bin/bash
```

It will also print the command to launch on the relay server to connect, something
like:

```shell
ssh runner@reverse
```

To disconnect and resume the execution of the action, in the reverse shell run:

```shell
rssh-stop
# or:
touch /tmp/continue
```

## TESTING

Follow the main setup instruction until compiling the `.env` file. Then run:

```shell
docker compose up
```

Finally connect to the launched container from the relay server.

The docker container is based on the image from [act](https://github.com/nektos/act).
