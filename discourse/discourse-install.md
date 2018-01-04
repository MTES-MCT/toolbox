# Discourse installation for MTES/MCT

> **Installation on _amd64_ and _Debian Jessie_**

---

## 1. Post-Installation OS

> **Execute these commands as** ```root``` **user**

### 1.1 __Set the proxy environment variables persistently for all users__
```shell
$ echo 'http_proxy=http://<adresse_proxy:port_proxy>; export http_proxy' >> /etc/bash.bashrc
$ echo 'https_proxy=http://<adresse_proxy:port_proxy>; export https_proxy' >> /etc/bash.bashrc
$ echo 'no_proxy="localhost,127.0.0.1,.mondomaine"; export no_proxy' >> /etc/bash.bashrc
```

### 1.2 __Install some essential packages__
```shell
$ apt-get install bash-completion openssh-server sudo
```

### 1.3 __Configuration mail server relay__
Un relai de mail est nécessaire pour transmettre les notifications de Discourse vers un serveur smtp
```shell
$ sudo apt-get install mailutils exim4
```
(ajouter un extrait de la configuration exim4)


---

## 2. System dependencies

> **Execute these commands as** ```admin``` **user**

### 2.1 __Git__
```shell
$ sudo apt-get install git-core
```

### 2.2 __Python requirements__
```shell
$ sudo apt-get install build-essential pkg-config python python-dev python-pip \
    libjpeg-dev zlib1g-dev libtiff5-dev libfreetype6-dev \
    liblcms2-dev libopenjpeg-dev libwebp-dev libpng12-dev \
    libxml2-dev  libxslt1-dev liblzma-dev libyaml-dev
```

### 2.3 __Docker__
#### 2.3.1 Installation
Install packages to allow ```apt``` to use a repository over HTTPS:
```shell
$ sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
```
Add Docker's official GPG key:
```shell
$ curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
```
Verify that the key ID is ```9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88```
```shell
$ sudo apt-key fingerprint 0EBFCD88

pub   4096R/0EBFCD88 2017-02-22
  Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid                  Docker Release (CE deb) <docker@docker.com>
sub   4096R/F273FCD8 2017-02-22
```
Set up the stable repository for amd64
```shell
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
```
Install the latest version of Docker
```shell
$ sudo apt-get update
$ sudo apt-get install docker-ce
```
Verify that Docker is installed correctly by running the ```hello-world``` image.
```shell
$ sudo docker run hello-world
```
This command downloads a test image and runs it in a container. When the container runs, it prints an informational message and exits.


#### 2.3.3 Configure Docker to start on boot
```shell
$ sudo systemctl enable docker
```

#### 2.3.4 Configure Docker behind proxy
Create a systemd drop-in directory for the docker service:
```shell
$ mkdir -p /etc/systemd/system/docker.service.d
```
Create a file called ```/etc/systemd/system/docker.service.d/http-proxy.conf``` that adds the ```HTTP_PROXY```, ```HTTPS_PROXY``` and ```NO_PROXY``` environment variable:
```shell
$ sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf

[Service]
Environment="HTTP_PROXY=http://<adresse_proxy:port_proxy>/" "HTTPS_PROXY=http://<adresse_proxy:port_proxy>/" "NO_PROXY=localhost,127.0.0.1,.mondomaine"
```
Flush changes
```shell
$ sudo systemctl daemon-reload
```
Restart Docker
```shell
$ sudo systemctl restart docker
```

### 2.4 __Docker-compose__ (optional)
Download the Docker Compose binary
```shell
sudo -i
curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
exit
```
Apply executable permissions to the binary
```shell
sudo chmod +x /usr/local/bin/docker-compose
```
Test the installation
```shell
docker-compose --version
```

---

## 3. Install and configure Discourse

> **Execute these commands as** ```root``` **user**

### 3.1 Downloading Discourse

```shell
$ mkdir /var/discourse
$ git config --global http.proxy http://<adresse_proxy:port_proxy>
$ git config --global https.proxy http://<adresse_proxy:port_proxy>
$ git config --global url."https://github.com/".insteadOf git://github.com/

$ git clone https://github.com/discourse/discourse_docker.git /var/discourse
```


### 3.2 Configuring Discourse

> **Execute these commands in discourse directory** (```/var/discourse```)

```shell
$ cd /var/discourse
$ ./discourse-setup
```

Hostname for your Discourse : e.g. discourse.domaine-name (need to use a domain name because an IP address won't work when sending email)
Email address for admin account
SMTP server address
SMTP user name
SMTP port
SMTP password


### 3.3 Reverse proxy Apache in front of discourse

Check and modify containers/app.yml




### 3.4 Reverse proxy Apache in front of discourse
Install apache
```shell
$ sudo apt-get install apache2
```
Install proxy and proxy_http modules for apache
```shell
$ sudo a2enmod proxy proxy_http
```
Create virtualhost for discourse : edit ```discourse.conf```
```shell
$ nano /etc/apache2/sites-available/discourse.conf

    <virtualhost discourse.domaine-name:80>
        ServerName discourse.domaine-name

        ProxyPass / http://127.0.0.1:8080/
        ProxyPassReverse / http://127.0.0.1:8080/
		ProxyRequests Off
    </virtualhost>
```
Enable the site and restart apache
```shell
$ sudo a2ensite discourse
$ sudo service apache2 restart
```


## 4. Upgrade Discours

> **Execute these commands as** ```root``` **user**
> **Execute these commands in discourse directory** (```/var/discourse```)

```shell
$ cd /var/discourse
$ export https_proxy=http://<adresse_proxy:port_proxy>
$ ./launcher rebuild app
```

