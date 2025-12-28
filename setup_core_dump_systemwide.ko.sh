#!/bin/bash

set -euo pipefail

# 이 스크립트는 sudo 로 실행 되어야 합니다.
# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "오류: 이 스크립트는 sudo (root 권한)로 실행해야 합니다."
    echo "예: sudo $0"
    exit 1
fi

# core 파일을 실행 디렉터리에 생성: core.<exe>.<pid>.<time>
CORE_PATTERN="core.%e.%p.%t"
# time 정보 읽는 예제: date -d @1735123456 '+%Y-%m-%d %H:%M:%S %Z'

# systemd-coredump 파이프 대신 파일로 생성하도록 전역 설정
sysctl -w kernel.core_pattern="${CORE_PATTERN}"

# (권장) core 덤프 파일 이름에 pid를 붙이므로 기존 덤프 덮어쓰기 위험 줄어듦
# core 파일 권한/경로는 프로세스 권한 및 실행 디렉터리 권한에 따릅니다.

echo "OK: kernel.core_pattern=${CORE_PATTERN}"
echo "NOTE: 이 설정은 시스템 전역이며 재부팅 후에도 유지될 수 있습니다(배포판 설정에 따라 다름)."

