#!bin/bash
cat <<'EOF' > /home/john/script.sh
wget -qO- https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | sudo apt-key add
sudo add-apt-repository "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu `lsb_release -cs` main"
wget https://github.com/edgelesssys/ego/releases/download/v0.4.0/ego_0.4.0_amd64.deb
sudo apt install -y ./ego_0.4.0_amd64.deb build-essential libssl-dev bison golang-go

rm ./ego_0.4.0_amd64.deb

bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source /home/john/.gvm/scripts/gvm
gvm install go1.17.4 --prefer-binary
gvm use go1.17.4 --default

yes | sudo ego install  az-dcap-client

git clone https://github.com/jonuwz/ego
mv /home/john/ego/samples .
rm -rf ego

EOF
chmod +x /home/john/script.sh
chown john /home/john/script.sh
