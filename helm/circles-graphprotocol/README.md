# Graph protocol for Circles

This chart installs graph protocol for circles with the following configuration:
- index node
- query node + proxy

It also add an extra middlewares to avoid spamming to the range of private IPs from IPFS

To upgrade any of the components please use `helm-upgrade-graph.sh` but beforehand you need to get hold of the k8s configuration to connect to the cluster and make sure you are in the right context.