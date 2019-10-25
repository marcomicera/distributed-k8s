# How do these scripts work
In order for these scripts to work, `~/.ssh/config` needs to have an entry called `distributed-k8s`:

```
Host distributed-k8s
  HostName <IP_ADDRESS>
  User kubernetes
  IdentityFile <PRIVATE_KEY>
```
