# Base install

# Add epel repository
#wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
cat > /etc/yum.repos.d/epel.repo << "EOF"
[epel]
name=Extra Packages for Enterprise Linux 6 - $basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
EOF

## Keep it simple - do not too much - rest should be made by puppet/chef/ansible or other Cfg. Mgm. Sys.
## Consider:
# Basic: firewall.sh
# Basic: sysctl.sh
# Basic: service_mgm.sh (chkconfig)
# Basic: box_hardening.sh (e.g. http://people.redhat.com/sgrubb/files/usgcb/rhel5/workstation-ks.cfg)
#or move it to ks.cfg?
