This script can be also called directly, without the github action.

This can be usefull to customize it or to use it in different environment.

As with the github action, create the ssh key pair and save the public key on
the relay server.

## SETUP

Checkout this repo with `git clone https://github.com/CarloDePieri/github_actions_shell.git`.

Now create a file `.env` using as template the [env.template](./env.template):

- `SSH_KEY`: The `github_action` private key;
- `SSH_RELAY_HOST`: The relay host PUBLIC ip / domain name;
- `SSH_RELAY_USER`: The user on the relay host;
- `SSH_RELAY_KEY`: A relay host public key (the first from `ssh-keyscan $SSH_RELAY_HOST`).

Now launch `./compile.sh`:

- if `xsel` is intalled, this will copy to the clipboard the compiled file;
- otherwise, the compiled file will be printed.

The compiled file can now be launched or customized.

