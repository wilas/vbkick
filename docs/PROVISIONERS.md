# Why

 - it's not easy to create good, fault tolerant scripts which can be executed multiple times
 - orchestration scripts may be challenging
 - already existing simple CM solutions
 - I couldn't have written it better myself: http://devopsu.com/blog/ansible-vs-shell-scripts/

# How

 Vbkick support any provisioner method, it's as simple as SCP files + run shell command via SSH (no magic voodoo).
 Instead of scp, you can use as well shared folders, git clone/pull, rsync to transfer needed files to destination boxes.

 Relevant section of definitions below (ansible and puppet as examples):
```
# ansible
postinstall_launch=(
    "cd postinstall && sudo bash adm_postinstall.sh adm_context_ansible.txt"
    "sudo ansible-playbook play_ansible/playbook.yaml -i play_ansible/ansible_inventory --connection=local"
)
postinstall_transport=(
    "postinstall"
    "play_ansible"
)

# puppet
postinstall_launch=(
    "cd postinstall && sudo bash adm_postinstall.sh adm_context_puppet.txt"
    "sudo puppet apply --hiera_config 'play_puppet/hiera.yaml' --modulepath 'play_puppet/modules' play_puppet/manifest.pp"
)
postinstall_transport=(
    "postinstall"
    "play_puppet"
)
```

 Full ansible and puppet examples are available [here](../examples/SL6_provisioner). In examples motd is configured via CMs, results below:

![provisioner-ansible](screens/provisioner-ansible.png)

![provisioner-puppet](screens/provisioner-puppet.png)

# Tips
 - do not overdesigne special for small jobs (save time and resources)
 - think about team - not everyone is expert or cares
 - postinstall scripts must be simple, bootstrat minimum to pass tasks to configuration management (or other tools like docker)
 - immediately stop script if any command fails - full control on return status and informations what exactly was wrong in script (it make debugging process simpler)
 - like the rocket start where your goal is to achive orbit without crashing (do one simple task - a lot of mistakes may be done, a lot of things may happen)
