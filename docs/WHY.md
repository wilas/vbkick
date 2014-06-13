# Why ?

After vagrant 1.1 release, veewee stoped working so nicely (veewee conflicts with vagrant 1.1+, dependency issues and other blablabla) - there are of course some workarounds available, but mixing the installed vagrant package, gem, rvm, bundle makes it unfriendly to work with:
 - https://github.com/jedi4ever/veewee/issues/607
 - https://github.com/jedi4ever/veewee/issues/611
 - https://github.com/mitchellh/vagrant/blob/v1.2.0/CHANGELOG.md#110-march-14-2013

I have decided write something light, which does one thing well, a tool that I can rely on. I think vbkick now does more than veewee did.

Vbkick works only with VirtualBox and there are no plans to support other platforms. Created and designed to be a personal lab where I can quickly hack and test new things without extra layers of abstraction. It lets me test the exact same commands which I run on prod without extra magic sauce or voodoo.

Low cost of failure = cheap experiments. Use `clone` and `snap` commands to save time during tinkering. `snap` to save the status of the fresh VM, later `resnap` to return to the start point, use clone to keep a "gold VM copy".

VirtualBox is good enough for lab needs to simulate bare metal with Solaris zones or Linux containers on board. Keep in mind that it is a toy - you shouldn't use it for production. The real production infrastructure should be designed and implemented for the needs of organization including costs etc. The nice feature of VirtualBox is portability between Linux, FreeBSD, MacOS, etc.

# Off topic

It would be nice to have a place on the web with various available distributions and some good practice. A place which allows you to easily start exploring a new OS, desktop environment or window manager. Letting you touch and taste things instead of just reading about them.

Note that without community it is impossible to create that place.
