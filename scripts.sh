###
 # @Author: clingxin
 # @Date: 2021-05-26 17:28:51
 # @LastEditors: clingxin
 # @LastEditTime: 2021-05-26 20:20:12
 # @FilePath: /minikube-spark/scripts.sh
###
#start and enable dashboard
minikube start --cpus=4 --memory=4g
minikube status
minikube addons enable dashboard
minikube dashboard
#check minikube status and create a namespace
kubetcl cluster-info --context minikube
#kubectl access the latest cluster which created in the node, need to specify the context which you want to access
kubectl get nodes --context minikube
kubectl create namespace spark
#install and add repo in helm, install spark in minikube in spark namespace
brew install helm
helm repo list
helm search repo spark
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-dev -n spark bitnami/spark
kubectl get all
#if you want to check the docker image and contain, you have to switch to the env in minikube
eval $(minikube docker-env)
docker info
#forward spark master ui port to 8088 which can access on localhost
kubectl port-forward --namespace spark svc/my-release-spark-master-svc 8088:80
#set env and execute the spark pi jobs
export EXAMPLE_JAR=$(kubectl exec -ti --namespace spark my-release-spark-worker-0 -- find examples/jars/ -name 'spark-example*\.jar' | tr -d '\r')
kubectl exec -ti --namespace default my-release-spark-worker-0 -- spark-submit --master spark://my-release-spark-master-svc:7077 \
    --class org.apache.spark.examples.SparkPi \
    $EXAMPLE_JAR 5