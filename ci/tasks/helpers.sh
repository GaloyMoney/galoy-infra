export GIT_REF="$(cat repo/.git/short_ref)"
export KUBE_CONFIG="~/.kube/config"

function init_kubeconfig() {
  cat <<EOF > ca.cert
${KUBE_CA_CERT}
EOF
  
  kubectl config set-cluster tf-backend --server=${KUBE_HOST} --certificate-authority="$(pwd)/ca.cert"
  kubectl config set-credentials tf-backend-user --token=${KUBE_TOKEN}
  kubectl config set-context tf-backend --cluster=tf-backend --user=tf-backend-user --namespace tf-backend
  kubectl config use-context tf-backend
}

function update_examples_git_ref() {
  sed -i'' "s/ref=.*\"/ref=${GIT_REF}\"/" bootstrap/main.tf
}
