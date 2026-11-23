#!/bin/ksh

# Environment variables
export time_max=10

if [[ ${STEP_NUM} == *"."* ]]; then
    STEP_NUM_C=${STEP_NUM#*.}
    CHARNUM=$(echo -n "${STEP_NUM_C}" | wc -c)
    echo "#DIGITS: ${CHARNUM}"
    if [[ ${CHARNUM} != 6 ]]; then
        echo "STEP_NUMBER: ${STEP_NUM}"
        echo "[ALERT] STEP_NUMBER variable after (.) should have exactly 6 digits. Found ${CHARNUM}. STEP_NUM = ${STEP_NUM}. E.g.: xx.xxxxxx"
        exit 1
    fi
fi
echo "STEP_NUMBER: ${STEP_NUM}"

timeout "$time_max" ssh -q -T c1_app@host02 'bash -s' <<EOF
if [ -d "/c1/c1_app/jenkins/jobs/C1DEV1B/builds/$BUILD_NUM/archive" ]; then
    echo "[COMMENT]: Release Job Build $BUILD_NUM is found in MW Env."
else
    echo "[ALERT]: Release Job Build $BUILD_NUM has not been copied from C1DEV1B to MW Env."   
    exit 1
fi
EOF

if [ $? -ne 0 ]; then
  	exit 1
else
    timeout "$time_max" scp -r c1_app@host02:/c1/c1_app/jenkins/jobs/C1DEV1B/builds/$BUILD_NUM/archive/* /c1/$NODE_NAME/work/jenkins/workspace/$JOB_NAME 2>/dev/null
    echo -e "[COMMENT]: Copied Buid ID $BUILD_NUM in $WORKSPACE.\n"
fi

install_release "$RELEASE_CODE"

#v1.0 23-may-2025