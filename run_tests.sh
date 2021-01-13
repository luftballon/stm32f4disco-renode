#!/bin/bash -e

# Runs Robot Framework tests locally

renode-test "${PWD}/tests/tests.yaml" --variable PWD_PATH:"${PWD}" -r "${PWD}/test_results"