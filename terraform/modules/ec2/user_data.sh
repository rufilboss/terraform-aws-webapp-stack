#!/bin/bash
sudo apt-get update
sudo apt-get install -y gdebi-core wget
wget https://download2.rstudio.org/connect/2022.02.0/rstudio-connect_2022.02.0_amd64.deb
sudo gdebi -n rstudio-connect_*.deb
systemctl start rstudio-connect