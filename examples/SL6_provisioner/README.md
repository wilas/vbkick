# How to

```
vbkick build sl6
# install guest additions
vbkick update sl6
vbkick snap sl6 fresh-install
vbkick shutdown sl6
vbkick clone sl6

vbkick on sl6
vbkick postinstall sl6 vbmachine-6.5-x86_64-ansible.cfg
SSH_CMD="ls -la" vbkick postinstall sl6 vbmachine-6.5-x86_64-ansible.cfg
vbkick ssh sl6 vbmachine-6.5-x86_64-ansible.cfg

vbkick shutdown sl6
vbkick resnap sl6

vbkick on sl6
vbkick postinstall sl6 vbmachine-6.5-x86_64-puppet.cfg
vbkick ssh sl6 vbmachine-6.5-x86_64-puppet.cfg

vbkick shutdown sl6
vbkick resnap sl6

vbkick on sl6
vbkick postinstall sl6 vbmachine-6.5-x86_64-docker.cfg
vbkick snap sl6 fresh-docker
vbkick play sl6 vbmachine-6.5-x86_64-docker.cfg
vbkick shutdown sl6
vbkick resnap sl6
vbkick on sl6
vbkick play sl6 vbmachine-6.5-x86_64-docker.cfg
vbkick ssh sl6 vbmachine-6.5-x86_64-docker.cfg

vbkick destroy sl6
```

For docker you may want read this: http://docs.docker.io/examples/running_ssh_service/
