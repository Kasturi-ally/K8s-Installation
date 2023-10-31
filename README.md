# K8s-Installation
# K8’s Installation - Debain-based Distro

There are some prerequisite for installation of kubernetes, so we will first install those and then install the k8s.

## **System Requirements:**

- [ ]  A linux host
- [ ]  2GB or more RAM per machine
- [ ]  2 CPU or more
- [ ]  Each should be in the same subnet or network
- [ ]  Swap should be disabled

## **************************Prerequisite:**************************

1. **Container Runtime** 🏃🏻‍♂️: Install a container runtime on each node so that pods can run there
    1. enable Forwarding IPv4 and let iptables see bridged traffic
    2. **Install docker** 🐋:
    Best way to install docker on any system is to download and script provided by docker and run. It will automatically install the docker.
        
        cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
        overlay
        br_netfilter
        EOF
        
        sudo modprobe overlay
        sudo modprobe br_netfilter
        
        # sysctl params required by setup, params persist across reboots
        cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
        net.bridge.bridge-nf-call-iptables  = 1
        net.bridge.bridge-nf-call-ip6tables = 1
        net.ipv4.ip_forward                 = 1
        EOF
        
        # Apply sysctl params without reboot
        sudo sysctl --system
        
        curl -fsSL [https://get.docker.com](https://get.docker.com/) -o [get-docker.sh](http://get-docker.sh/)
        sudo sh ./get-docker.sh 
        
    3. **Start and enable docker service**
        
        sudo systemctl start docker
        sudo systemctl status docker
        sudo systemctl enable docker
        sudo docker ps
        
    4. **Enable the containerd plugin and restart docker and containerd service**
        
        enable a containerd plugin in /etc/containerd/config.toml
        
        sudo vi /etc/containerd/config.toml 
        sudo systemctl restart containerd
        sudo systemctl restart docker
        

---

## Installing kubeadm, kubelet and kubectl

1. Update the apt package and install packages needed to use the kubernetes apt repository
    
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
    
2. Download the Google cloud public signing key
    
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
    
3. Add the Kubernetes apt repository
    
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    
4. Update apt package index, install kubelet, kubeadm and kubectl
    
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    

### Now Kubernetes is installed successfully we have to create a cluster using kubeadm

Creating a cluster using kubeadm

Run kubeadm init to initalise the cluster

sudo kubeadm init

To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Till here the cluster is created successfully and if try to get nodes.

### Now we will add a worker node for that we have to follow the same procedure till installation of kubernetes components

**Add ports in security groups** 
for example add All TCP ports in inbound rule

On control plane get the token to be add on worker-node

kubeadm token create - - print-join-command

Copy the output and paste it on the worker node and you will output like this

🥳 we can see the worker node in our kubernetes cluster

But there status is NotReady, this is because we need to add a network plugin so that we have an overlay network to communicate with nodes and pod easily

on controlplane:
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

Now check the status of nodes.

Your K8s cluster is ready!!
