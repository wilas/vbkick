# Troubleshooting:

## kickstart port is already in use.

Port 7130 as an example:
```
  $ vbkick build example
  7130 port (kickstart) is already in use.

  # check what use given port
  $ netstat -tulpn | grep 7130
  $ nc -z localhost 7130
```
