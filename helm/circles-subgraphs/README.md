### Deploying subgraphs in self-hosted subgraph

To deploy a subgraph plese use the command below, prior to get the necessary credentials. 

 kubectl apply -f <SUBGRAPH.YML> -n graph

If the  jobs fails, you will have to delete the job manually from k8s and relaunch it again 