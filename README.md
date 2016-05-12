Garuda
======


Set of deployment scripts for continuous integration and deployment using Docker and Vagrant.

Essentially, the `provision.sh` Bash script file sets up a CentOS7 build machine.


## Memento

### Docker

* Build Docker images for Centos7 build machine.

  ```
  cd centos7
  docker build -t docv-centos7 .
  ```

* Start CentOS7 Docker container with a Bash shell to debug the provision script.

  ```
  docker run -it docv-centos bash
  ```
