#!/bin/bash


##########  Packages and base requirements

if [ ! -f /home/vagrant/.vagrant-bootstrap-complete ]; then
        # Always take this information from the official wiki: https://github.com/zhdk/leihs/wiki
        # NOTE: Do not install mysql-server here, as that would ask for a password using a dialog, and we can't do that
        # on the Vagrant shell.
        sudo apt-get install --assume-yes build-essential make libxslt-dev libcairo2-dev libmysqlclient-dev libxml2-dev curl make build-essential git libxslt-dev libcairo2-dev libmysqlclient-dev libxml2-dev libreadline6-dev libssl-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev imagemagick libcurl4-openssl-dev apache2-prefork-dev apache2 mysql-client libmagickwand-dev


        # So we can use 'ifdata' to show the IP address of this host later on.
        sudo apt-get install --assume-yes moreutils

        # Latest versions of iceweasel come from backports
        sudo cp /vagrant/doc/vagrant/iceweasel.list /etc/apt/sources.list.d/iceweasel.list
        sudo apt-get update
        sudo apt-get install pkg-mozilla-archive-keyring
        sudo gpg --check-sigs --fingerprint --keyring /etc/apt/trusted.gpg.d/pkg-mozilla-archive-keyring.gpg --keyring /usr/share/keyrings/debian-keyring.gpg pkg-mozilla-maintainers
        sudo apt-get update

        # Prerequisites for running our tests
        #sudo apt-get install --assume-yes xvfb

        # Probably better, since some people want to actually watch the browser while it tests
        sudo apt-get install --assume-yes tightvncserver xbase-clients fluxbox
        sudo apt-get install -t wheezy-backports --assume-yes iceweasel

        # Without this, installing MySQL will prompt for a MySQL root password, but we can't
        # enter one in this noninteractive shell. With the noninteractive option set, the
        # package will simply use a blank root password.
        sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes mysql-server

        ########## RVM, Ruby and bundler

        # Only RVM is supported by Passenger. Cannot use rbenv.
        # Also, only RVM has a good system-wide install.
        if [ ! -f /usr/local/bin/rvm ]; then
                sudo curl -L https://get.rvm.io | bash -s stable
                sudo usermod -a -G rvm vagrant
        fi


        if [ ! -f /home/vagrant/.vagrant-setup-complete ]; then
                echo "#################### WARNING ########################"
                echo "############ YOU ARE NOT DONE YET ###################"
                echo ""
                echo "If this is the *first time* you use this Vagrant box,"
                echo "you have to log in as user 'vagrant' and run this:"
                echo ""
                echo "      bash /vagrant/vagrant-setup.sh "
                echo ""
                echo "############ YOU ARE NOT DONE YET ###################"
                echo "#################### WARNING ########################"
                echo ""
        fi

        touch /home/vagrant/.vagrant-bootstrap-complete
fi

LOCAL_IP=`ifdata -pa eth1`
echo "############## Network information ###############"
if [[ -z "$LOCAL_IP" ]]; then
        echo "It appears that your guest machine's eth1 interface is"
        echo "not configured. Are you sure bridged networking"
        echo "is working correctly? If not, you will not be able"
        echo "to use this VM properly. You must have a DHCP server"
        echo "running on the same network as one of your host machine's"
        echo "network devices to use this machine the way it's intended."
        echo ""
        echo "If you *cannot* provide such a network setup, you must"
        echo "customize your Vagrantfile yourself and figure out all"
        echo "this networking shit yourself."
else
        echo "This virtual machine's IP is: $LOCAL_IP"
        echo "You may have to point some hostnames from your"
        echo "host machine to this IP address."
        echo ""
        echo "For example:"
        echo ""
        echo "$LOCAL_IP    leihs.vagrant"
        echo ""
        echo "Then access leihs *in production mode* at:"
        echo ""
        echo "      http://leihs.vagrant"
        echo ""
        echo "Or run 'rails s' and go through port forwarding:"
        echo ""
        echo "      http://localhost:3000"
        echo ""
        echo "The local port 8080 on your host is *additionally*"
        echo "forwarded to port 80 on the guest. So you can connect"
        echo "to your Vagrant box's Apache in production like so:"
        echo ""
        echo "      http://localhost:8080"
        echo ""
        echo "Also, the VNC port 5901 on the guest is forwarded to"
        echo "5901 on your host. So connect to localhost::5901 if"
        echo "you're running a VNC server in the guest ('tightvncserver')."
        echo ""
        echo "If you want fancier networking, e.g. host-only or"
        echo "bridged networking, you must configure that yourself."
        echo ""
fi
