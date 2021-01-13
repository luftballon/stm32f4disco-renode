#!/bin/bash -e

# Originally written by TensorFlow at
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/lite/micro/testing/test_stm32f4_binary.sh
#
# -------------------------------------------------------
#
# Runs Robot Framework tests in Docker and saves results locally

declare -r HOST_ROOT_DIR=`pwd`
declare -r HOST_TEST_RESULTS_PATH=${HOST_ROOT_DIR}/test_results
declare -r HOST_LOG_PATH=${HOST_TEST_RESULTS_PATH}
declare -r HOST_LOG_FILENAME=${HOST_LOG_PATH}/logs.txt

declare -r DOCKER_TAG=renode_stm32f4
declare -r DOCKER_WORKSPACE=/workspace
declare -r DOCKER_TEST_RESULTS_PATH=/tmp/test_results

mkdir -p ${HOST_LOG_PATH}

docker build -t ${DOCKER_TAG} -f ${HOST_ROOT_DIR}/Dockerfile .

# running in `if` to avoid setting +e

exit_code=0
if ! docker run \
  --log-driver=none -a stdout -a stderr \
  --volume ${HOST_ROOT_DIR}:${DOCKER_WORKSPACE} \
  --volume ${HOST_TEST_RESULTS_PATH}:${DOCKER_TEST_RESULTS_PATH} \
  --workdir ${DOCKER_WORKSPACE} \
  ${DOCKER_TAG} \
  /bin/bash -c "./run_tests.sh 2>&1 > ${DOCKER_TEST_RESULTS_PATH}/logs.txt"
then
  echo "FAILED"
  exit_code=1
fi

echo -e "\n----- LOGS -----\n"
cat ${HOST_LOG_FILENAME}

if [ $exit_code -eq 0 ]
then
  echo "$1: PASS"
else
  echo "$1: FAIL"
fi

# Raise the exit
exit $exit_code
