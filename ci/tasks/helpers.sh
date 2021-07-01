export MODULES_GIT_REF="$(cat modules/.git/short_ref)"
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

function init_bootstrap() {
  cd bootstrap
  cat <<EOF > override.tf
terraform {
  backend "kubernetes" {
    secret_suffix = "testflight"
    namespace = "concourse-tf"
  }
}
EOF

  terraform init
}

function init_tf() {
  for folder in "$@"; do
    pushd $folder
    terraform init
    popd
  done
}

function update_examples_git_ref() {
  if [[ "${MODULES_GIT_REF}" == "" ]]; then
    echo "MODULES_GIT_REF is empty"
    exit 1
  fi

  echo "Bumping examples to '${MODULES_GIT_REF}'"
  sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" bootstrap/main.tf
  sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" inception/main.tf
}

function make_commit() {
  if [[ -z $(git config --global user.email) ]]; then
    git config --global user.email "bot@galoy.io"
  fi
  if [[ -z $(git config --global user.name) ]]; then
    git config --global user.name "CI Bot"
  fi

  
  (cd $(git rev-parse --show-toplevel)
    git merge --no-edit ${BRANCH}
    git add -A
    git status
    git commit -m "$1"
  )
}
