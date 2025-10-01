mkdir archlinux
sudo chown -R catalin:catalin archlinux
distrobox create --name arch --image docker.io/library/archlinux:latest --home /home/archlinux
