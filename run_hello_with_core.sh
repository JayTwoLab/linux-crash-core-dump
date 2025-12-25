#!/bin/bash

# 이 스크립트는 hello 프로그램을 실행하여 코어 덤프를 생성합니다.
# 
# 이 스크립트를 사용하기 전에, setup_core_dump_systemwide.sh 스크립트를 통해 
# 시스템 전역 코어 덤프 설정을 해야 합니다.
# 설정하지 않으면 coredump 파일이 생성되지 않습니다. 

set -euo pipefail

# 작업 디렉터리 및 실행 파일 경로 설정
WORKDIR="/home/jaytwo/workspace/coredump-workspace"
EXEC="${WORKDIR}/hello"

cd "${WORKDIR}"

# 코어 덤프 허용 (현재 쉘/프로세스에만 적용)
ulimit -c unlimited

# ASAN/UBSAN 설정 (필요시)
export ASAN_OPTIONS="abort_on_error=1:disable_coredump=0"
export UBSAN_OPTIONS="halt_on_error=1:abort_on_error=1"

# 실행
"${EXEC}"

# 정상 종료면 여기까지 옴(크래시 시에는 보통 도달하지 않음)
echo "프로그램이 정상 종료되었습니다."

