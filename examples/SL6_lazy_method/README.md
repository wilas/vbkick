```
drwxr-xr-x  .
drwxr-xr-x. ..
lrwxrwxrwx  definition.cfg -> definition-6.4-x86_64-full.cfg
-rw-r--r--  definition-6.3-x86_64.cfg
-rw-r--r--  definition-6.4-x86_64.cfg
-rw-r--r--  definition-6.4-x86_64-full.cfg
drwxr-xr-x  iso
drwxr-xr-x  keys
drwxr-xr-x  kickstart
drwxr-xr-x  postinstall
drwxr-xr-x  validate
```

```
vbkick build SL6_lazy
vbkick postinstall SL6_lazy
vbkick validate SL6_lazy
vbkick export SL6_lazy

vagrant box add 'SL64_lazy' SL6_lazy.box
vagrant box list
```
