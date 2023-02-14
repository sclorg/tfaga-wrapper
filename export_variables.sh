#!/bin/sh

public_ranch="centos7 c9s fedora"
private_ranch="rhel7 rhel8 rhel9 rhel9-unsubscribed"
all_os="$public_ranch $private_ranch"

os_test="$1"   # options: centos7, c9s, fedora, rhel7, rhel8, rhel9, rhel9-unsubscribed
test_case="$2" # options: container, openshift-3, openshift-4
if [ -z "$os_test" ] || ! echo "$all_os" | grep -q "$os_test" ; then
  echo "::error::os_test '$os_test' is not valid"
  echo "::warning::choose one of: $all_os"
  exit 5
fi

# container tests vs openshift tests
case "$test_case" in
  "container")
    test_case="container"
    tmt_plan_suffix="-docker"
    context_suffix=""
    test_name="test"
    ;;
  "openshift-3")
    context_suffix=" - OpenShift 3"
    tmt_plan_suffix="-openshift-3"
    test_name="test-openshift"
    ;;
  "openshift-4")
    context_suffix=" - OpenShift 4"
    tmt_plan_suffix="-openshift-4"
    test_name="test-openshift-4"
    ;;
  ""|*)
    echo "::error::test_case '$test_case' is not valid"
    exit 5
    ;;
esac



# public vs private ranch
if echo "$public_ranch" | grep -q "$os_test" ; then
  api_key="public_api_key"
  branch="main"
  tf_scope="public"
  tmt_repo="https://github.com/sclorg/sclorg-testing-farm"
else
  api_key="private_api_key"
  branch="master"
  tf_scope="private"
  tmt_repo="https://gitlab.cee.redhat.com/platform-eng-core-services/sclorg-tmt-plans"
fi

# variables based on operating system in test
dockerfile=Dockerfile."$os_test"
case "$os_test" in
  "centos7")
    tmt_plan="centos7"
    context="CentOS7$context_suffix"
    dockerfile="Dockerfile"
    compose="CentOS-7"
    ;;
  "c9s")
    tmt_plan="c9s"
    context="CentOS Stream 9"
    compose="CentOS-Stream-9"
    ;;
  "fedora")
    tmt_plan="fedora"
    context="Fedora"
    compose="Fedora-latest"
    ;;
  "rhel7")
    tmt_plan="rhel7$tmt_plan_suffix"
    context="RHEL7$context_suffix"
    compose="RHEL-7-LatestUpdated"
    ;;
  "rhel8")
    tmt_plan="rhel8$tmt_plan_suffix"
    context="RHEL8$context_suffix"
    compose="RHEL-8.6.0-Nightly"
    ;;
  "rhel9")
    tmt_plan="rhel9$tmt_plan_suffix"
    context="RHEL9$context_suffix"
    compose="RHEL-9.1.0-Nightly"
    ;;
  "rhel9-unsubscribed")
    os_test="rhel9"
    dockerfile="Dockerfile.$os_test"
    tmt_plan="rhel9-unsubscribed-docker"
    context="RHEL9 - Unsubscribed host"
    compose="RHEL-9.1.0-Nightly"
    ;;
  ""|*)
    echo "::error::os_test '$os_test' is not valid"
    exit 5
    ;;
esac

# shellcheck disable=SC2129
echo "api_key=$api_key"   >> "$GITHUB_OUTPUT"
echo "branch=$branch"     >> "$GITHUB_OUTPUT"
echo "tf_scope=$tf_scope" >> "$GITHUB_OUTPUT"
echo "tmt_repo=$tmt_repo" >> "$GITHUB_OUTPUT"
echo "os_test=$os_test"   >> "$GITHUB_OUTPUT"
echo "tmt_plan=$tmt_plan" >> "$GITHUB_OUTPUT"
echo "context=$context"   >> "$GITHUB_OUTPUT"
echo "compose=$compose"   >> "$GITHUB_OUTPUT"
echo "test_name=$test_name" >> "$GITHUB_OUTPUT"
echo "dockerfile=$dockerfile" >> "$GITHUB_OUTPUT"
