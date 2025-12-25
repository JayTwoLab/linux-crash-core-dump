# Linux coredump 

- Linux C/C++ 프로그램의 코어 덤프 생성, 분석, 관리 자동화 예제

## 구성 파일

- **main.cpp**  
   - 고의로 segmentation fault를 발생시키는 간단한 C++ 예제입니다.  
   - 빌드 예시:
   ```
   g++ -g -O0 -Wall -Wextra -o hello main.cpp
   ```
   - AddressSanitizer/UBSanitizer 사용:
   ```
   g++ -g -O0 -Wall -Wextra -fsanitize=address,undefined -fno-omit-frame-pointer -o hello main.cpp
   ```

- **setup_core_dump_systemwide.sh**  
   - 시스템 전체에 core dump 파일이 생성되도록 core_pattern을 설정합니다.  
   ```
   sudo ./setup_core_dump_systemwide.sh
   ```
   - core 파일명 패턴: `core.<exe>.<pid>.<time>`

- **run_hello_with_core.sh**  
   - hello 프로그램을 실행하여 core dump를 생성합니다.  
   - 실행 전 systemwide 설정이 필요합니다.

- **run_hello_with_core_daemon.sh**  
   - hello 프로그램을 데몬 형태로 반복 실행합니다.  
      - 프로그램이 종료될 때마다 자동 재시작
      - core dump 허용 및 ASAN/UBSAN 환경변수 설정
      - 로그 파일(hello_daemon.log)은 10MB를 초과하면 최근 10,000줄만 남기고 오래된 내용은 삭제됨

- **gdb_hello_core.sh**  
  - 생성된 core dump 파일을 gdb로 분석하는 스크립트입니다.
   ```
   ./gdb_hello_core.sh <core_dump_file>
   ```

- **list_core_with_time.sh**  
  - 현재 디렉터리의 core 파일 목록과 각 파일의 타임스탬프(사람이 읽기 쉬운 시간)를 출력합니다.

## 사용 예시

1. core dump 시스템 설정  
   ```
   sudo ./setup_core_dump_systemwide.sh
   ```

2. hello 빌드  
   ```
   g++ -g -O0 -Wall -Wextra -o hello main.cpp
   ```

3. core dump 생성  
   ```
   ./run_hello_with_core.sh
   ```

4. core 파일 목록 확인  
   ```
   ./list_core_with_time.sh
   ```

5. core 분석  
   ```
   ./gdb_hello_core.sh core.hello.<pid>.<time>
   ```

6. 데몬 실행  (또는 `run_hello_with_core.sh`로 1회 실행)
   ```
   ./run_hello_with_core_daemon.sh
   ```

