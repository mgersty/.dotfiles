#!/bin/bash
if [[ -z "${1}" ]]; then
    echo "Please provide an artifact id"
    exit 1;
fi
ARTIFACT_ID="${1}"
echo "Creating Java Project: org.gersty.${ARTIFACT_ID}"
mvn archetype:generate -B \
    -DarchetypeGroupId=org.gersty \
    -DarchetypeArtifactId=java11-template \
    -DarchetypeVersion=1.0.0 \
    -DgroupId=org.gersty \
    -DartifactId="${ARTIFACT_ID}" \
    -Dversion=0.1.0-SNAPSHOT \
    -Dpackage=org.gersty.${ARTIFACT_ID} \
    -DoutputDirectory=${HOME}/sandbox/java/

