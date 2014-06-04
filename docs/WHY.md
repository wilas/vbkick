# Why ?

After vagrant 1.1 release, veewee stop working in a nice way (veewee conflicts with vagrant 1.1+, dependency issues and other blablabla) - there are of course some workaround available, but mixing installed vagrant package, gem, rvm, bundle in not pleasant in use:
 - https://github.com/jedi4ever/veewee/issues/607
 - https://github.com/jedi4ever/veewee/issues/611
 - https://github.com/mitchellh/vagrant/blob/v1.2.0/CHANGELOG.md#110-march-14-2013

I have decided write something light, what do one thing well, a tool that I can rely on. I think vbkick do now more than veewee did.

Vbkick works only with the VirtualBox and there is no plans to support other platforms. Created and design to be a personal lab where I can quickly hack and test new things without extra abstraction layer. Test the exactly same commands which I run on prod without extra magic sauce or voodoo.

Low cost of failure = cheap experiments. Use `clone` and `snap` commands to save a time during tinkering. `snap` to save the status of the fresh VM, later `resnap` to return to the start point, use clone to keep a "gold VM copy".

VirtualBox is enough good for a lab needs to simulate bare metal with Solaris zones or Linux containers on board. Keep in mind that it is a toy - you shouldn't use it for production. The real production infrastructure should be designed and implemented for the needs of organization including costs etc. The nice feature of VirtualBox is portability between Linux, FreeBSD, MacOS, etc.

# Off topic

It would be nice to have a place in the web with various available distributions and some good practice. Place which allow easily start adventure with a new OS, desktop environment or window manager. Allow to touch and taste things not only read about them.

Note that without community it is impossible to create that place.
