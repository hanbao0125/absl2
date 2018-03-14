# Created on 2018-03-12 8:54PM

grep -rn "" * 显示行号 *当前目录下所有文件

find /dir -name filename  在/dir目录及其子目录下面查找名字为filename的文件
需要从安装folder下sudo + 脚本名

10:15PM - sudo env PATH=/home/ubuntu/.rbenv/shims:/home/ubuntu/.rbenv/bin:/home/ubuntu/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin bundle exec ./bin/nise-bosh --keep-monit-files -y ../cf-release ../manifests/deploy.yml micro_ng -n 172.16.0.13 必须在目录nise_bosh里执行。

sudo apt-get install nethogs
sudo nethogs

# 2018-03-13 11:01AM
sudo env PATH=/home/ubuntu/.rbenv/shims:/home/ubuntu/.rbenv/bin:/home/ubuntu/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin bundle exec ./bin/nise-bosh --keep-monit-files -y ../cf-release ../manifests/deploy.yml micro_ng -n 172.16.0.13

## start successfully

* Login: cf login -a https://api.172.16.0.13.xip.io -u admin -p c1oudc0w --skip-ssl-validation
* Download CF CLI from https://github.com/cloudfoundry/cli

sudo /var/vcap/bosh/bin/monit summary

Clipboard sharing requires that the VirtualBox Guest Additions be installed. As a result, this setting has no effect otherwise;
For drag and drop to work the Guest Additions need to be installed **on the guest**.

To make this work, a special mouse driver is **installed in the guest** that communicates with the "real" mouse driver on your host and moves the guest mouse pointer accordingly.

prepare your guest system for building external kernel modules.

[uːˈbuːntuː] 

What is **vboxdrv** ? - VirtualBox Linux kernel driver

In order to run other operating systems in virtual machines alongside your main operating system, VirtualBox needs to integrate very tightly into the system. To do this it installs a "driver" module called vboxdrv which does a lot of that work into the system kernel, which is the part of the operating system which controls your processor and physical hardware.

Like the Windows Guest Additions, the VirtualBox Guest Additions for Linux are a set of device drivers and system applications which may be installed in the guest operating system.

lsb_release -a

# 2018-03-14

finding the version name of your kernel using the command **uname -r** in a terminal
APT is a package management system for Debian and other Linux distributions based on it, such as Ubuntu.
sudo apt-get install virtualbox-guest-additions-iso,after that the iso is in folder /usr/share/virtualbox/VBoxGuestAdditions.iso

## solution 10:40AM
$ sudo apt-get clean
$ sudo apt-get autoclean
$ sudo apt-get -f install
