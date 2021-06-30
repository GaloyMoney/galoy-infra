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
  echo "Bumping examples to '${GIT_REF}'"
  sed -i'' "s/ref=.*\"/ref=${GIT_REF}\"/" bootstrap/main.tf
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
