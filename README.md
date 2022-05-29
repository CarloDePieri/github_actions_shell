A github action to create a reverse ssh connection between a github workflow and
a public server.

This can be handy to inspect and debug a failing workflow job.

## Setup

A public host that acts as relay is needed, with `sshd` installed.

Generate a custom ssh key pair with `ssh-keygen github_actions`. Add the resulting
public key to the `authorized_keys` on the relay server.

Create a action secret called `RSSH_ENV` and paste the value of [env.template](./env.template);
fill in the values:

- `SSH_KEY`: The `github_action` private key;
- `SSH_RELAY_HOST`: The relay host PUBLIC ip / domain name;
- `SSH_RELAY_USER`: The user on the relay host;
- `SSH_RELAY_KEY`: A relay host public key (the first from `ssh-keyscan $SSH_RELAY_HOST`).

Hint: this completed value can be stored to quickly reuse this setup with
different projects.

Finally, add to the workflow file:

```yaml
- name: Launch a reverse ssh connection.
  uses: CarloDePieri/github_actions_shell@v1
  with:
    rssh_env: ${{ secrets.RSSH_ENV }}
    # optionally:
    rssh_relay_port: 10022
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
    # optionally:
    rssh_relay_port: 10022
```

## Usage

Launch the github action, manually or with the ci. The job will enter a loop, suggesting
to add something like this to `.ssh/config` on the relay server:

```config
Host reverse
        HostName localhost
        User runner
        Port 10022
        RequestTTY force
        RemoteCommand /bin/bash
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        LogLevel ERROR
```

It will also print the command to launch on the relay server to connect, something
like:

```shell
ssh reverse
```

To disconnect and resume the execution of the action, in the reverse shell run:

```shell
gh-continue
# or:
touch /tmp/continue
```

## Testing the script locally

Clone this repo with `git clone https://github.com/CarloDePieri/github_actions_shell.git`.

Enter the test folder with `cd test`.

Create `env.full` and `env.split` starting from [env.full.template](test/env.full.template)
and [env.split.template](test/env.split.template) respectively (pay
attention to delimeters and escaped charatecters).

Then run:

```shell
make test-full
# or:
make test-split
```

This will allow to login in the container from the relay server and test the script.

