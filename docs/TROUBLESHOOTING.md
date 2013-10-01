# Troubleshooting:

## kickstart port is already in use.

Port 7130 as an example:
```
  $ vbkick build example
  7130 port (kickstart) is already in use.

  # check whether python webserver from previous build was killed
  $ ps -ef | grep python | grep 7130
  $ kill PID

  # check what use given port
  $ netstat -tulpn | grep 7130
  $ nc -z localhost 7130
```
