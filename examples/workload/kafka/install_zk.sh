kubectl create namespace kafka-test
kubectl -n kafka-test apply -f ./zookeeper-deployment.yaml
sleep 400
#zk集群验证
for i in {0..1}; do kubectl -n kafka-test exec zk-$i -- hostname; done
sleep 2
for i in {0..1}; do echo "myid zk-$i";kubectl -n kafka-test exec zk-$i -- cat /var/lib/zookeeper/data/myid; done
sleep 2
for i in {0..1}; do kubectl -n kafka-test exec zk-$i -- hostname -f; done
sleep 2
#暴露外部服务
for i in {0..1}; do kubectl -n kafka-test label pod zk-$i zkInst=$i; done
sleep 2
for i in {0..1}; do kubectl -n kafka-test expose po zk-$i --port=2181 --target-port=2181 --name=zk-$i --selector=zkInst=$i --type=NodePort; done
sleep 4000
#部署kafka
kubectl -n kafka-test apply -f ./kafka-deployment.yaml
sleep 300
#kafka集群验证
for i in {0..1}; do kubectl -n kafka-test exec kafka-$i -- hostname -f; done
sleep 10
#暴露外部服务
for i in {0..1}; do kubectl -n kafka-test label pod kafka-$i kafkaInst=$i; done
sleep 20
for i in {0..1}; do kubectl -n kafka-test expose po kafka-$i --port=9093 --target-port=9093 --name=kafka-$i --selector=kafkaInst=$i --type=NodePort; done


