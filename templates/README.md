# Place for official vbkick OS templates

## Overview

Each template is stored in a separate git submodule with person taking care about it.

By default template defines Vagrant Base Box, so in each template vagrant user is created.

## templates sctructure (good practice)

```
    .
    ├── RedHat6_box
    │   ├── definition.cfg
    │   ├── definition62.cfg
    │   ├── definition63.cfg
    │   ├── definition64.cfg
    │   ├── kickstart
    │   │   └── <redhat63-x86_64-JDK.cfg, redhat64-x86_64-noX.cfg, ...>
    │   └── postinstall
    │       └── <adm_postinstall.sh, adm_context.txt, adm_envrc, base.sh, cleanup.sh, puppet.sh, ruby.sh, virtualbox.sh, ....sh >
    ├── RedHat5_box
    │   ├── definition.cfg
    │   ├── definition55.cfg
    │   ├── definition56.cfg
    │   ├── definition59.cfg
    │   ├── kickstart
    │   │   └── <redhat56-x86_64-puppet.cfg, redhat59-i386-noX.cfg, ...>
    │   └── postinstall
    │       └── <adm_postinstall.sh, adm_context.txt, adm_envrc, base.sh, cleanup.sh, puppet.sh, ruby.sh, virtualbox.sh, ....sh >
    └── Debian6_box
        ├── definition.cfg
        ├── definition600.cfg
        ├── definition607.cfg
        ├── kickstart
        │   └── <Debian6-x86_64-KDE.cfg, Debian6-i386-noX.cfg, ...>
        └── postinstall
            └── <adm_postinstall.sh, adm_context.txt, adm_envrc, base.sh, cleanup.sh, puppet.sh, ruby.sh, virtualbox.sh, ....sh >
```

```
    drwxr-xr-x  .
    drwxr-xr-x. ..
    lrwxrwxrwx  definition.cfg -> definition64_injection.cfg
    -rw-r--r--  definition63_lazy.cfg
    -rw-r--r--  definition63_injection.cfg
    -rw-r--r--  definition64_lazy.cfg
    -rw-r--r--  definition64_injection.cfg
    drwxr-xr-x  iso
    drwxr-xr-x  keys
    drwxr-xr-x  kickstart
    drwxr-xr-x  postinstall
    -rw-r--r--  LICENSE
    -rw-r--r--  README.md
```

howto update symlink:
```
    ln -fs definition63_injection.cfg definition.cfg
```

Description:
 - postinstall dir contain all scripts run during postinstall process
 - kickstart dir contain all files used during boot/kickstart process
 - each file in kickstart (e.g. ks.cfg/preseed.cfg) has descriptive names (OS_NAMEVERSION-ARCH-SPEC_DESC.cfg) e.g.: redhat63-x86_64-noX.cfg, redhat64-x86_64-JDK.cfg, debian700-x86_64-KDE.cfg
 - definition.cfg is symlink to default vbkick definition
 - each definition has descriptive name e.g. definition63.cfg, definition64.cfg, definition65_beta.cfg, definition64_injection.cfg
 - each template take care about "big" OS release, e.g. RedHat6, Redhat5, Debian7, Debian6
 - OS ISOs and SSH keys are not included
 - README.md and LICENSE files are required

## vbkick templates hall of fame

 - ScientificLinux6 <@wilas>
 - RedHat ?
 - Debian ?
 - Ubuntu ?
 - FreeBSD ?
 - Gentoo ?
 - SmartOS ?
 - OpenIndiana ?
