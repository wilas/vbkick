# List 3rd party repositories: http://wiki.centos.org/AdditionalResources/Repositories

# Add EL repository
## rpm --import http://elrepo.org/RPM-GPG-KEY-elrepo.org
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org http://elrepo.org/RPM-GPG-KEY-elrepo.org
## rpm -Uvh http://elrepo.org/elrepo-release-6-5.el6.elrepo.noarch.rpm
cat > /etc/yum.repos.d/elrepo.repo << "EOF"
[elrepo]
name=ELRepo.org Community Enterprise Linux Repository - el6
baseurl=http://elrepo.org/linux/elrepo/el6/$basearch/
mirrorlist=http://elrepo.org/mirrors-elrepo.el6
enabled=0
gpgcheck=1
protect=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
EOF

# Add EPEL repository
## rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
## rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm or
## rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
cat > /etc/yum.repos.d/epel.repo << "EOF"
[epel]
name=Extra Packages for Enterprise Linux 6 - $basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
EOF

# Add Atrpms repository
## rpm --import http://packages.atrpms.net/RPM-GPG-KEY.atrpms
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-atrpms http://packages.atrpms.net/RPM-GPG-KEY.atrpms
## rpm -Uvh http://dl.atrpms.net/all/atrpms-repo-6-6.el6.$(uname -m).rpm
cat > /etc/yum.repos.d/atrpms.repo << "EOF"
[atrpms]
name=Red Hat Enterprise Linux $releasever - $basearch - ATrpms
baseurl=http://dl.atrpms.net/el$releasever-$basearch/atrpms/stable
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-atrpms
failovermethod=priority
EOF

# Add Remi repository
## rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-remi http://rpms.famillecollet.com/RPM-GPG-KEY-remi
## rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
cat > /etc/yum.repos.d/remi.repo << "EOF"
[remi]
name=Les RPM de remi pour Enterprise Linux $releasever - $basearch
mirrorlist=http://rpms.famillecollet.com/enterprise/6/remi/mirror
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
failovermethod=priority
EOF
