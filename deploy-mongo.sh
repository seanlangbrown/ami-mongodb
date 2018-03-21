# update installed packages
echo "[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc" |
  sudo tee -a /etc/yum.repos.d/mongodb-org-3.4.repo

  echo "[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc" |
  sudo tee -a /etc/yum.repos.d/mongodb-org-3.4.repo

  # create mount points mount each volume, set ownershi
  sudo mkdir /data /log /journal

sudo mkfs.xfs /dev/sdb
# sudo mkfs.xfs /dev/xvdg
# sudo mkfs.xfs /dev/xvdh

echo '/dev/xvdf /data xfs defaults,auto,noatime,noexec 0 0
/dev/xvdg /journal xfs defaults,auto,noatime,noexec 0 0
/dev/xvdh /log xfs defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab

sudo mount /data
sudo mount /journal
sudo mount /log

sudo chown mongod:mongod /data /journal /log

sudo ln -s /journal /data/journal

# configure mongo parameters
dbpath = /data
logpath = /log/mongod.log

#adjust ulimit for mongo
echo '* soft nofile 64000
* hard nofile 64000
* soft nproc 64000
* hard nproc 64000' | sudo tee /etc/security/limits.d/90-mongodb.conf

#set write ahead limits, make persistant
sudo blockdev --setra 0 /dev/sdb
echo 'ACTION=="add|change", KERNEL=="xvdf", ATTR{bdi/read_ahead_kb}="0"' | sudo tee -a /etc/udev/rules.d/85-ebs.rules

# # Once again, repeat the above command for all required volumes (note: the device we created was named /dev/xvdf but the name used by the system is xvdf).
# sudo blockdev --setra 0 /dev/xvdg
# echo 'ACTION=="add|change", KERNEL=="xvdg", ATTR{bdi/read_ahead_kb}="0"' | sudo tee -a /etc/udev/rules.d/85-ebs.rules

# sudo blockdev --setra 0 /dev/xvdh
# echo 'ACTION=="add|change", KERNEL=="xvdh", ATTR{bdi/read_ahead_kb}="0"' | sudo tee -a /etc/udev/rules.d/85-ebs.rules

#set keepalive time
sudo sysctl -w net.ipv4.tcp_keepalive_time=300
#set keepalive time in persistant way
echo "net.ipv4.tcp_keepalive_time = 300" >> /etc/sysctl.conf

sudo service mongod start
sudo chkconfig mongod on