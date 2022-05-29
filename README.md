## To Install the infrastructure please use the following instructions: 

 * First of all please review a variables available in variables.tf 
 > You can see an example in the file tf-dev.tfvars 

```
   cd infrastructure-terrafrom/
   terraform init
   terraform apply -var-file=tf-dev.tfvars -lock=false
```
  
* After this operation you will get a new file kubeconfig_aws-dev-es-cloud created in the folder
>You can use it to get Access to the K8S cluster in AWS

## To Install ElaciSearch into the K8s cluster 

 ### Install ES Cloud Operator CRD's and Operator itself
``` 
   kubectl create -f https://download.elastic.co/downloads/eck/2.2.0/crds.yaml
   kubectl apply -f https://download.elastic.co/downloads/eck/2.2.0/operator.yaml
```
 * Create Namespace for elastic deployment

```   kubectl create ns elastic-deployment```

 * Change directory YAML target deployments

```   cd k8s-es-operator/target-deployments/```

 * Then apply - HA Clusters of Elastic and Kibana. And for example APM server.

```   
      kubectl apply  -f es-cloud.yaml -n elastic-deployment
      kubectl apply  -f metricbeat.yaml -n elastic-deployment
```

 * Get Public Https endpoints Elastic at TCP 9200 and Kibana at TCP 5601

```   
   kubectl get services -n elastic-deployment | grep LoadBalancer
   es-api-cluster-es-http LoadBalancer 172.20.144.47 a541219cc0c7f491d9b5369ac7e98307-975159938.eu-central-1.elb.amazonaws.com 9200:31378/TCP 103m
   kb-es-cluster-kb-http LoadBalancer 172.20.90.121 a1742ae9cd96443e985a73c0dc84f52a-1315731882.eu-central-1.elb.amazonaws.com 5601:32483/TCP 103m
```

 * Now you can log in to Kibana with the following credentials 

```
   Kibana: https://a1742ae9cd96443e985a73c0dc84f52a-1315731882.eu-central-1.elb.amazonaws.com:5601/login
   ES_9200: https://a541219cc0c7f491d9b5369ac7e98307-975159938.eu-central-1.elb.amazonaws.com:9200/_cluster/health/
```
 **User:** naviteq 

 **Password:** theshining