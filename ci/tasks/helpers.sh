alias tf=tofu
export MODULES_GIT_REF="$(cat modules/.git/short_ref)"
export MODULES_GIT_LONG_REF="$(cat modules/.git/ref)"
export KUBE_CONFIG="~/.kube/config"
export CI_ROOT="$(pwd)"
export CI_ROOT_DIR="${CI_ROOT##*/}"
export TF_VAR_name_prefix="testflight$(cat testflight-uid/version | tr -d .)"

function init_gcloud() {
  cat <<EOF > ${CI_ROOT}/gcloud-creds.json
${GOOGLE_CREDENTIALS}
EOF
  cat <<EOF > ${CI_ROOT}/login.ssh
${SSH_PRIVATE_KEY}
EOF
  chmod 600 ${CI_ROOT}/login.ssh
  cat <<EOF > ${CI_ROOT}/login.ssh.pub
${SSH_PUB_KEY}
EOF
  SERVICE_ACCOUNT=$(cat ${CI_ROOT}/gcloud-creds.json | jq -r '.client_email')
  echo "    --> gcloud auth activate-service-account with user $SERVICE_ACCOUNT"
  gcloud auth activate-service-account --key-file ${CI_ROOT}/gcloud-creds.json
  echo "    --> gcloud config set project \"${TF_VAR_gcp_project}\""
  gcloud config set project "${TF_VAR_gcp_project}"
}

function init_bootstrap_gcp() {
  pushd bootstrap
  echo "    --> Verifying bootstrap state directory exists"
  if [ ! -d ../../../../bootstrap-tf-state ]; then
    echo "    --> bootstrap.tfstate does not exist, exiting"
    exit 1
  fi
  cat <<EOF > override.tf
terraform {
  backend "local" {
    path = "../../../../bootstrap-tf-state/bootstrap.tfstate"
  }
}
EOF
  echo "    --> tofu init"
  tofu init
  popd
}

function write_users() {
   echo ${TESTFLIGHT_ADMINS} | \
     jq --arg sa "$(cat ${CI_ROOT}/gcloud-creds.json | jq -r '.client_email')" \
     '{ users: [ .[] | { id: ., inception: true, platform: true, logs: true, bastion: true }, { id: "serviceAccount:\($sa)", inception: true, platform: true, logs: true, bastion: true } ]}' > inception/users.auto.tfvars.json
}

function write_azure_users() {
  echo ${TESTFLIGHT_ADMINS} | \
    jq '{ users: [ .[] | { id: ., inception: true, platform: true, logs: true, bastion: true } ]}' > inception/users.auto.tfvars.json
}

function cleanup_inception_key() {
  pushd bootstrap
  inception_email=$(tofu output inception_sa | jq -r)
  popd
  key_id="$(cat ./inception-sa-creds.json | jq -r '.private_key_id')"
  gcloud iam service-accounts keys delete "${key_id}" --iam-account="${inception_email}" --quiet
}

function update_examples_git_ref() {
  if [[ "${MODULES_GIT_REF}" == "" ]]; then
    echo "MODULES_GIT_REF is empty"
    exit 1
  fi

  echo "    --> Bumping examples to '${MODULES_GIT_REF}'"
  sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" bootstrap/main.tf
  sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" inception/main.tf
  sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" platform/main.tf
  sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" postgresql/main.tf
  sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" smoketest/main.tf
}

function config_git() {
  echo "    --> git user config"

  if [[ -z $(git config --global user.email) ]]; then
    git config --global user.email "202112752+blinkbitcoinbot@users.noreply.github.com"
  fi
  if [[ -z $(git config --global user.name) ]]; then
    git config --global user.name "CI blinkbitcoinbot"
  fi
}

function make_commit() {
  config_git

  echo "    --> git merge (${BRANCH}) + commit -m '${1}'"
  (cd $(git rev-parse --show-toplevel)
    git merge --no-edit ${BRANCH}
    git add -A
    git status
    git commit -m "$1"
  )
}
