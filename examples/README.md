# Examples

Open Source mean freedom – enjoy that freedom and choose best solution for you.


## injection postinstall method (my fav.)
```
vbkick build SL6_inject
vbkick export SL6_inject

vagrant box add 'SL64_inject' SL6_inject.box
vagrant box list
```

## lazy postinstall method
```
vbkick build SL6_lazy
vbkick postinstall SL6_lazy
vbkick export SL6_lazy

vagrant box add 'SL64_lazy' SL6_lazy.box
vagrant box list
```
