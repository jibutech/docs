# mysql8 workload example

## installation steps

```
[root@gyj-dev ~]# helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" already exists with the same configuration, skipping

[root@gyj-dev ~]# helm search repo bitnami/mysql -l |grep 8.2.3
bitnami/mysql  8.2.3          8.0.22           Chart to create a Highly available MySQL cluster


[root@gyj-dev mysql-example]# helm install mysql bitnami/mysql --version 8.2.3 -n mysql-test --create-namespace  -f ./mysql-values.yaml
NAME: mysql
LAST DEPLOYED: Tue Jan 11 21:49:10 2022
NAMESPACE: mysql-test
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

Tip:

  Watch the deployment status using the command: kubectl get pods -w --namespace mysql-test

Services:

  echo Primary: mysql-primary.mysql-test.svc.cluster.local:3306
  echo Secondary: mysql-secondary.mysql-test.svc.cluster.local:3306

Administrator credentials:

  echo Username: root
  echo Password : $(kubectl get secret --namespace mysql-test mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode)

To connect to your database:

  1. Run a pod that you can use as a client:

      kubectl run mysql-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.22-debian-10-r44 --namespace mysql-test --command -- bash

  2. To connect to primary service (read/write):

      mysql -h mysql-primary.mysql-test.svc.cluster.local -uroot -p my_database

  3. To connect to secondary service (read-only):

      mysql -h mysql-secondary.mysql-test.svc.cluster.local -uroot -p my_database

To upgrade this helm chart:

  1. Obtain the password as described on the 'Administrator credentials' section and set the 'root.password' parameter as shown below:

      ROOT_PASSWORD=$(kubectl get secret --namespace mysql-test mysql} -o jsonpath="{.data.mysql-root-password}" | base64 --decode)
      helm upgrade mysql bitnami/mysql --set auth.rootPassword=$ROOT_PASSWORD#
```