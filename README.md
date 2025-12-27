# Linux coredump 

- Linux C/C++ 프로그램의 코어 덤프 생성, 분석, 관리 자동화 예제

---

<br />

## 구성 파일

- **main.cpp**  
   - 고의로 segmentation fault를 발생시키는 간단한 C++ 예제(`main.cpp`)입니다.
      - ```cpp
        int main() {
          std::string *ptr = NULL;
          ptr->clear(); // crash here
          return 0;
        }
        ```
   - `Debug` 빌드 예시:
   ```bash
   g++ -g -O0 -Wall -Wextra -o hello main.cpp
   ```
   - `AddressSanitizer`/`UBSanitizer` 사용:
   ```bash
   g++ -g -O0 -Wall -Wextra -fsanitize=address,undefined -fno-omit-frame-pointer -o hello main.cpp
   ```
	- `AddressSanitizer` (`ASan`) : 메모리 오류를 실행 중에 탐지합니다.
	   - 탐지 가능한 오류
		  - 힙/스택 버퍼 오버플로우
		  - use-after-free (해제 후 접근)
		  - double free
		  - 메모리 누수
		  - 스택 오버플로우
	   - 특징
		  - 런타임에 메모리 접근을 감시
		  - 오류 발생 시 정확한 스택 트레이스 출력
		  - 성능 오버헤드 존재 (약 2~3배)
	- `UndefinedBehaviorSanitizer` (`UBSan`) : C++ 표준에서 정의되지 않은 동작(Undefined Behavior)을 탐지합니다.
	   - 탐지 가능한 오류
		  - 정수 오버플로우
		  - 잘못된 형변환
		  - nullptr 역참조
		  - 배열 범위 초과
		  - 잘못된 메모리 정렬 접근
		  - 잘못된 enum 값 사용
	   - 특징
		  - 논리 오류 탐지에 효과적
		  - ASan보다 가벼움
		  - 크래시 전에 경고 출력 가능
      
---

<br />

- **setup_core_dump_systemwide.sh**  
   - 시스템 전체에 core dump 파일이 생성되도록 core_pattern을 설정합니다.  
   ```bash
   sudo ./setup_core_dump_systemwide.sh
   ```
   - core 파일명 패턴: `core.<exe>.<pid>.<time>`
      - `<exe>` : 실핼 프로그램명
      - `<pid>` : 프로세스 아이디
      - `<time>` : epoch time
         - `date -d @<time> '+%Y-%m-%d %H:%M:%S %Z'` 명령으로 시간정보를 볼 수 있다.  

---

<br />

- **run_hello_with_core.sh**  
   - hello 프로그램을 실행하여 core dump를 생성합니다.  
   - 실행 전 systemwide 설정이 필요합니다.
   - 실행 프로그램(`hello`)의 파일명돠 경로를 설정합니다.
   ```bash
    # 작업 디렉터리 및 실행 파일 경로 설정
    WORKDIR="/home/jaytwo/workspace/coredump-workspace"
    EXEC="${WORKDIR}/hello"
   ``` 

---

<br />

- **run_hello_with_core_daemon.sh**  
   - hello 프로그램을 데몬 형태로 반복 실행합니다.  
      - 프로그램이 종료될 때마다 자동 재시작
      - core dump 허용 및 ASAN/UBSAN 환경변수 설정
      - 로그 파일(hello_daemon.log)은 10MB를 초과하면 최근 10,000줄만 남기고 오래된 내용은 삭제합니다.
      ```bash
      # 로그 파일 크기 제한: 10MB 초과 시 최근 10000줄만 남김
      MAX_LOG_SIZE=10485760 # 10MB
      MAX_LOG_LINES=10000
      if [ -f "${LOG}" ] && [ $(stat -c%s "${LOG}") -ge $MAX_LOG_SIZE ]; then
          tail -n $MAX_LOG_LINES "${LOG}" > "${LOG}.tmp" && mv "${LOG}.tmp" "${LOG}"
          echo "[$(date '+%F %T')] log trimmed to last $MAX_LOG_LINES lines" >> "${LOG}"
      fi
      ```
      - 실행 파일명 및 경로를 설정 후 사용합니다.
      ```bash
      # 작업 디렉터리 및 실행 파일 경로 설정
      WORKDIR="/home/jaytwo/workspace/coredump-workspace"
      EXEC="${WORKDIR}/hello"
      ```
  
---

<br />

- **gdb_hello_core.sh**  
  - 생성된 core dump 파일을 gdb로 분석하는 스크립트입니다.
   ```bash
   ./gdb_hello_core.sh <core_dump_file>
   ```
  - 실행 파일명 및 경로를 설정 후 사용합니다.
  ```bash
   # 작업 디렉터리 및 실행 파일 경로 설정
   WORKDIR="/home/jaytwo/workspace/coredump-workspace"
   EXEC="${WORKDIR}/hello"
  ```     

---

<br />

- **list_core_with_time.sh**  
  - 현재 디렉터리의 core 파일 목록과 각 파일의 타임스탬프(사람이 읽기 쉬운 시간)를 출력합니다.

---

<br />

## 사용 예시

- (1) core dump 시스템 설정  
   ```bash
   sudo ./setup_core_dump_systemwide.sh
   ```
   - 이 설정은 반드시 superuser 계정 권한이 필요함
- (2) 실행 프로그램(hello) 빌드 (Debug 심볼이 추가되도록 빌드한다.)  
   ```bash
   g++ -g -O0 -Wall -Wextra -o hello main.cpp
   ```
- (3) core dump 생성  
   ```bash
   ./run_hello_with_core.sh
   ```
   - core.실행프로그램맹.프로세스아이디.시간 형식의 파일이 생성됨
- (4) core 파일 목록 확인  
   ```bash
   ./list_core_with_time.sh
   ```
- (5) core 분석  
   ```bash
   ./gdb_hello_core.sh core.hello.<pid>.<time>
   ```
   - gdb 명령 `r` : run
   - gdb 명령 `bt full` : 현재 스레드의 호출 스택 (지역 변수 값까지 포함)
   - gdb 명령 `list` 라인수 : 소스코드 표시
- (6) 데몬 실행 
   ```
   ./run_hello_with_core_daemon.sh
   ```
   - 또는, `run_hello_with_core.sh`로 1회 실행

## 스크립트 자동 구동 설치 방법
   - [설치 방법](INSTALL.md)
    
