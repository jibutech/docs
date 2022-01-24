#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage: ./hack/restore-application.sh <backupname>"
    exit 1
fi

backupname=$1
veleroNamespace=qiming-backend
timeout=600

date="$(date +%s)"
veleroInstallerPodName=`kubectl get -n "$veleroNamespace" pods -l app=velero-installer |grep Running | awk '{print $1}'`
restoreName=restore-${date}
echo "`date` Trigger velero restore on backup $backupname ..."
kubectl exec -n "$veleroNamespace" -it "$veleroInstallerPodName" -- bash -c "./qiming/velero restore create ${restoreName} --from-backup ${backupname}"
restoreStatus=`kubectl get -n $namespace restores.velero.io $restoreName -o=jsonpath='{.status.phase}'`
restoreTimeout=$(($date + $timeout))
while [[ "$restoreStatus" != "Completed" ]]; do
    currentTime="$(date +%s)"
    if (( $currentTime > $restoreTimeout )); then
        echo "`date` Restore timeout"
        exit 1
    fi
    echo "`date` Velero restore status $restoreStatus ..."
    restoreStatus=`kubectl get -n $veleroNamespace restores.velero.io $restoreName -o=jsonpath='{.status.phase}'`
    sleep 5
done

echo "`date` Velero restore completed."