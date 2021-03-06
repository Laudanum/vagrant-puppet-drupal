# http://www.how2centos.com/centos-6-puppet-install/
releasever=6
basearch=x86_64

# Install the Puppet Repository
echo "[puppetlabs]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/el/$releasever/products/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs" > /etc/yum.repos.d/puppet.repo

# Install the EPEL x86_64 YUM Repository 
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-7.noarch.rpm

# Install the Puppet Client packages
sudo yum -y install puppet
