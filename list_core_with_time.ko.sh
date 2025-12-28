#!/bin/bash

# 이 스크립트는 현재 디렉터리에서 시간 정보(%t)가 포함된 core 파일들을 찾아서
# 각 파일명과 해당 타임스탬프를 사람이 읽을 수 있는 형식으로 변환하여 출력합니다.

set -euo pipefail

shopt -s nullglob

FOUND=0

for f in core.*; do
    # 마지막 '.' 이후를 timestamp로 간주
    ts="${f##*.}"

    # 숫자인지 확인
    if [[ "$ts" =~ ^[0-9]+$ ]]; then
        # epoch → 사람이 읽는 시간
        human_time="$(date -d "@$ts" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo '변환 실패')"

        printf "%-40s  %s\n" "$f" "$human_time"
        FOUND=1
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "현재 디렉터리에 시간 정보(%t)가 포함된 core 파일이 없습니다."
fi

