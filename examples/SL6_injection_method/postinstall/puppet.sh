# Puppet Labs repositories
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
cat > /etc/yum.repos.d/puppetlabs.repo << "EOF"
[puppetlabs-products]
name=Puppet Labs Products EL 6 - $basearch
baseurl=http://yum.puppetlabs.com/el/6/products/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs

[puppetlabs-deps]
name=Puppet Labs Dependencies EL 6 - $basearch
baseurl=http://yum.puppetlabs.com/el/6/dependencies/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs

[puppetlabs-devel]
name=Puppet Labs Devel EL 6 - $basearch
baseurl=http://yum.puppetlabs.com/el/6/devel/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs

[puppetlabs-products-src]
name=Puppet Labs Products EL 6 - $basearch - Source
baseurl=http://yum.puppetlabs.com/el/6/products/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs

[puppetlabs-deps-src]
name=Puppet Labs Dependencies EL 6 - $basearch - Source
baseurl=http://yum.puppetlabs.com/el/6/dependencies/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs

[puppetlabs-devel-src]
name=Puppet Labs Devel EL 6 - $basearch - Source
baseurl=http://yum.puppetlabs.com/el/6/devel/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
EOF

# Req. by puppet:
#yum -y --enablerepo=puppetlabs-deps install ruby-augeas ruby-shadow
# Install puppet
yum -y --enablerepo=puppetlabs-products,puppetlabs-deps install hiera puppet facter

# If older/frozen version needed:
#yum -y --enablerepo=puppetlabs-deps install ruby-augeas-0.4.1-1.el6
#yum -y --enablerepo=puppetlabs-deps install ruby-shadow-1.4.1-13.el6
#yum -y --enablerepo=puppetlabs-products install hiera-1.1.2-1.el6
#yum -y --enablerepo=puppetlabs-products install puppet-3.1.0-1.el6
#yum -y --enablerepo=puppetlabs-deps install facter-1.6.17-1.el6
