cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    sudo sysctl --system
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh 
    systemctl restart docker
    systemctl enable docker
    sed -i 's/disabled/enable/' /etc/containerd/config.toml
    sed -i 's/cri/containerd/' /etc/containerd/config.toml
   systemctl restart containerd
   systemctl enable containerd
   sudo apt-get update
   sudo apt-get install -y apt-transport-https ca-certificates curl
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
   sudo apt-get update
   sudo apt-get install -y kubelet kubeadm kubectl