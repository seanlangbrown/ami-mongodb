# update installed packages
echo "[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc" |
  sudo tee -a /etc/yum.repos.d/mongodb-org-3.4.repo

sudo yum -y update && sudo yum install -y mongodb-org-server \
    mongodb-org-shell mongodb-org-tools
  # create mount points mount each volume, set ownershi
  # sudo mkdir /data /log /journal

sudo mkdir -p /data /log /journal

sudo mkfs.xfs -f /dev/sdb

echo '/dev/sdb /data xfs defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab

sudo mount /data

sudo chown mongod:mongod /data /journal /log

sudo ln -s /journal /data/journal

# configure mongo parameters
echo "dbpath = /data" >> /etc/mongod.conf
echo "logpath = /log/mongod.log" >> /etc/mongod.conf

#adjust ulimit for mongo
echo '* soft nofile 64000
* hard nofile 64000
* soft nproc 64000
* hard nproc 64000' | sudo tee /etc/security/limits.d/90-mongodb.conf

#set write ahead limits, make persistant
sudo blockdev --setra 0 /dev/sdb
echo 'ACTION=="add|change", KERNEL=="sdb", ATTR{bdi/read_ahead_kb}="0"' | sudo tee -a /etc/udev/rules.d/85-ebs.rules

#set keepalive time
sudo sysctl -w net.ipv4.tcp_keepalive_time=300
#set keepalive time in persistant way
echo "net.ipv4.tcp_keepalive_time = 300" >> /etc/sysctl.conf

sudo service mongod start
sudo chkconfig mongod on