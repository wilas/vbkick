# Validate

Check already created virtual machine with defined features (Has a new VM Guest expected behaviour?).

Test should be smart enough to check what I really want to test, e.g. If I do not need chef, do not test whether I have chef.

Validate process is very similar to lazy postinstall method. Transport scripts via SCP and exec them using SSH command.

## adm_features.sh

Easy way to administer features/tests.
```
adm_context.txt         # list of scrips run by adm_features.sh (order matter), you can also use comments
adm_envrc               # list of env. variables (may be used by all scripts) - help keep important variables in one place, e.g. Virtualbox version
adm_features.sh         # take care about exec other scripts (features)
```

Use adm_features.sh is a convenient manner, but not mandatory.

## BDD like

We don’t need to use BDD tools to use BDD principles: http://chrismdp.com/2013/03/bdd-with-shell-script/

Howto print steps - readable documentation, [examples](examples/SL6_injection_method/)
```
$ cat validate/*.sh | grep -E "^# (Feature|Scenario|And|Given|When|Then)"

# Given a new Virtualbox Guest
# Feature: ansible provisioner
# Given ansible command
# When I run "ansible --version" command
# Then I expect success
# Feature: chef provisioners
# Given chef-client command
# And chef-solo command
# When I run "chef-client --version" command
# And I run "chef-solo --version" command
# Then I expect success
# Feature: puppet provisioner
# Given puppet command
# When I run "puppet --version" command
# Then I expect success
# Feature: ruby interpreter
# Given ruby command
# When I run "ruby --version" command
# Then I expect success
# Feature: sudoers has disabled requiretty
# Given /etc/sudoers file
# When I grep /etc/sudoers file 
# Then requiretty is disabled
# Feature: vagrant user
# Given vagrant user
# When I login using ssh key
# And I run sudo command
# Then I expect success
# Feature: Virtualbox Guest Additions
# Given VBoxControl command
# When I run "VBoxControl --version" command
# Then I expect version is up-to-date
```

