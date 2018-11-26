#!/usr/bin/env/ sh

set -e

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a quoted commit message'
    exit 1
fi
COMMIT_MSG="${1}"

# Compile the zola site using the docker container
docker-compose run zola zola build

# Don't publish if the build fails
if [[ $? -ne 0 ]] ; then
    exit 1
fi

GITHUB_PUBLISH_REPO=master
ZOLA_BUILD_DIR=./public
CNAME=tjtelan.com

# TODO: Move this pipenv code into the docker container to keep tools off the host
# Publish the locally compiled site to github
pipenv run ghp-import -n -c ${CNAME} -b ${GITHUB_PUBLISH_REPO} -m ${COMMIT_MSG} -p ${ZOLA_BUILD_DIR}
