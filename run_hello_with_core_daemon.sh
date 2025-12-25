#!/bin/bash

# 이 스크립트는 hello 프로그램을 데몬 형태로 실행하여
# 프로그램이 종료될 때마다 재시작합니다.
# 
# 이 스크립트를 사용하기 전에, setup_core_dump_systemwide.sh 스크립트를 통해 
# 시스템 전역 코어 덤프 설정을 해야 합니다.
# 설정하지 않으면 coredump 파일이 생성되지 않습니다. 

set -euo pipefail

# 작업 디렉터리 및 실행 파일 경로, 로그 파일 경로 설정
WORKDIR="/home/jaytwo/workspace/coredump-workspace"
EXEC="${WORKDIR}/hello"
LOG="${WORKDIR}/hello_daemon.log"

cd "${WORKDIR}"

# 코어 덤프 허용 (이 스크립트가 실행하는 hello에 적용)
ulimit -c unlimited

# ASAN/UBSAN 설정 (필요시)
export ASAN_OPTIONS="abort_on_error=1:disable_coredump=0"
export UBSAN_OPTIONS="halt_on_error=1:abort_on_error=1"

# 데몬 시작 로그 기록
echo "[$(date '+%F %T')] daemon start" >> "${LOG}"

# 로그 파일 크기 제한: 10MB 초과 시 최근 10000줄만 남김
MAX_LOG_SIZE=10485760 # 10MB
MAX_LOG_LINES=10000
if [ -f "${LOG}" ] && [ $(stat -c%s "${LOG}") -ge $MAX_LOG_SIZE ]; then
    tail -n $MAX_LOG_LINES "${LOG}" > "${LOG}.tmp" && mv "${LOG}.tmp" "${LOG}"
    echo "[$(date '+%F %T')] log trimmed to last $MAX_LOG_LINES lines" >> "${LOG}"
fi

while true; do

    # 실행 시작 로그 기록
    echo "[$(date '+%F %T')] starting hello" >> "${LOG}"

    # 실행
    "${EXEC}"
    rc=$?

    # 종료 로그 기록
    echo "[$(date '+%F %T')] hello exited rc=${rc}" >> "${LOG}"

    # 너무 빠른 재시작 방지
    sleep 600 # seconds

    # NOTE: crash에 의한 소프트웨어 정지가 원인일 확률이 높으며, 
    # 그럴 경우 재시작하여도 동일한 문제가 반복될 수 있습니다. 
    # 이 점 유의하시기 바랍니다.
done


