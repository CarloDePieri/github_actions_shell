A script to create a reverse ssh connection between a github action and a public
server.

This can be handy to inspect and debug a failing action.

## SETUP

A public host that acts as relay is needed, with `sshd` installed.

Create a custom ssh key pair with `ssh-keygen github_actions`. Add the resulting
public key to the `authorized_keys` on the relay server.

Checkout this repo with `git clone https://github.com/CarloDePieri/github_actions_shell.git`.

Now create a file `.env` using as template the [env.template](./env.template):

- `SSH_KEY`: The `github_action` private key;
- `SSH_RELAY_HOST`: The relay host PUBLIC ip / domain name;
- `SSH_RELAY_USER`: The user on the relay host;
- `SSH_RELAY_KEY`: A relay host public key (the first from `ssh-keyscan $SSH_RELAY_HOST`).

Now launch `./compile.sh`:

- if `xsel` is intalled, this will copy to the clipboard the compiled file;
- otherwise, the compiled file will be printed.

Paste it in the value of a github action secret called `RSSH_SCRIPT`.

Finally, in the action file:

```yaml
- name: Launch a reverse ssh connection.
  run: |
    cat >>~/run-reverse-ssh <<END
    $RSSH_SCRIPT
    END
    chmod +x ~/run-reverse-ssh
    ~/run-reverse-ssh
  env:
    RSSH_SCRIPT: ${{ secrets.RSSH_SCRIPT }}
```

### Alternative setup

As before, create the ssh key pair and save the public key on the server.

Create some github action secrets:

- `RSSH_SCRIPT`: the content of [script.sh](./script.sh);
- `SSH_KEY`: The `github_action` private key;
- `SSH_RELAY_HOST`: The relay host PUBLIC ip / domain name;
- `SSH_RELAY_USER`: The user on the relay host;
- `SSH_RELAY_KEY`: A relay host public key (the first from `ssh-keyscan $SSH_RELAY_HOST`).

Then, in the action file:

```yaml
- name: Launch a reverse ssh connection.
  run: |
    cat >>~/run-reverse-ssh <<END
    $RSSH_SCRIPT
    END
    chmod +x ~/run-reverse-ssh
    ~/run-reverse-ssh
  env:
    RSSH_SCRIPT: ${{ secrets.RSSH_SCRIPT }}
    SSH_KEY: ${{ secrets.SSH_KEY }}
    SSH_RELAY_HOST: ${{ secrets.SSH_RELAY_HOST }}
    SSH_RELAY_USER: ${{ secrets.SSH_RELAY_USER }}
    SSH_RELAY_KEY: ${{ secrets.SSH_RELAY_KEY }}
```

## USAGE

Launch the github action, manually or with the ci. The job will enter a loop, suggesting
to add something like this to `.ssh/config` on the relay server:

```config
Host reverse
    HostName localhost
    StrictHostKeyChecking no
    Port 10022
```

It will also print the command to launch on the relay server to connect, something
like:

```shell
ssh runner@reverse
```

To disconnect and resume the execution of the action, in the reverse shell run:

```shell
touch /tmp/continue
```

## TESTING

Follow the main setup instruction until compiling the `.env` file. Then run:

```shell
docker compose up
```

Finally connect to the launched container from the relay server.

The docker container is based on the image from [act](https://github.com/nektos/act).
