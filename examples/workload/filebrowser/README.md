# build frontend

replace logo.png

change image tag to swr registry if use cce:

cd nginx && docker build . -t jibutech/cce-demo-frontend:v0.0.1

docker push jibutech/cce-demo-frontend:v0.0.1

# install

helm install fb ./helm-charts/cce-demo/ -n cce-demo --create-namespace

# uninstall

helm -n cce-demo uninstall fb
