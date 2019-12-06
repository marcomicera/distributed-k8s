# Remote `rsync`-based utility scripts

This folder contains scripts based on `rsync` that aim to facilitate the synchronization of file between the local machine and a remote one.

### [`push.sh`](https://github.com/marcomicera/distributed-k8s/blob/master/scripts/remote/push.sh)

The [`push.sh`](https://github.com/marcomicera/distributed-k8s/blob/master/scripts/remote/push.sh) script uploads (with `rsync`) the fundamental files of this repository to a remote machine.

Its only optional argument represents the host machine name.
Its default value is the `distributed-k8s` alias, that needs such an entry in the `~/.ssh/config` file:
```
Host distributed-k8s
  HostName <IP_ADDRESS>
  User <USERNAME>
  IdentityFile <PRIVATE_KEY>
```
