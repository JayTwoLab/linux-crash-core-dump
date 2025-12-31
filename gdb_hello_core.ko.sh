#!/bin/bash

# 이 스크립트는 지정된 core 덤프 파일을 gdb로 분석하기 위해 실행됩니다.

set -euo pipefail
 
# 작업 디렉터리 및 실행 파일 경로 설정
WORKDIR="/home/jaytwo/workspace/coredump-workspace"
EXEC="${WORKDIR}/hello"

# 인자 확인
if [ $# -ne 1 ]; then
    echo "사용법: $0 <core_dump_file>"
    echo "예:   $0 core.hello.18078.1766666152"
    exit 1
fi
# core.프로그램이름.프로세스아이디.시간에서 시간정보 얻는 방법은 date -d "@시간" 으로 변환 가능
# date -d "@1766666152" '+%Y-%m-%d %H:%M:%S %Z'
# 또는 ./list_core_with_time.sh 스크립트를 사용한다.

CORE_FILE="$1"

# 경로 이동
cd "${WORKDIR}"

# core 파일 존재 확인
if [ ! -f "${CORE_FILE}" ]; then
    echo "오류: core 파일이 존재하지 않습니다: ${CORE_FILE}"
    exit 1
fi

# 실행 파일 확인
if [ ! -x "${EXEC}" ]; then
    echo "오류: 실행 파일이 존재하지 않거나 실행 불가: ${EXEC}"
    exit 1
fi

echo "gdb 실행:"
echo "  exe : ${EXEC}"
echo "  core: ${CORE_FILE}"
echo

# gdb 실행
gdb "${EXEC}" "${CORE_FILE}"

