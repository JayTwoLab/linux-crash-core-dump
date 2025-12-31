# Linux Coredump

[Korean README](README.ko.md)

- Example project for generating, analyzing, and managing core dumps for Linux C/C++ (gcc) programs.

---

<br />

## File Overview

- **main.cpp**  
  - A simple C++ example that intentionally causes a segmentation fault.
    ```cpp
    int main() {
      std::string *ptr = NULL;
      ptr->clear(); // crash here
      return 0;
    }
    ```
  - Debug build example:
    - command 
      ```bash
      g++ -g -O0 -Wall -Wextra -o hello main.cpp
      ```
     - cmake
      ```cmake
      if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
          target_compile_options(hello PRIVATE
              -g
              -O0
              -Wall
              -Wextra
          )
      endif()    
      ``` 
  - Using AddressSanitizer / UBSanitizer:
    - command
      ```bash
      g++ -g -O0 -Wall -Wextra -fsanitize=address,undefined -fno-omit-frame-pointer -o hello main.cpp
      ```
    - cmake
      ```cmake
      if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
          target_compile_options(hello PRIVATE
              -g
              -O0
              -Wall
              -Wextra
              -fsanitize=address,undefined
              -fno-omit-frame-pointer
          )
      
          target_link_options(hello PRIVATE
              -fsanitize=address,undefined
          )
      endif()      
      ``` 
  - **AddressSanitizer (ASan)**: Detects memory errors at runtime  
    - Detectable issues:
      - Heap/stack buffer overflow
      - Use-after-free
      - Double free
      - Memory leaks
      - Stack overflow
    - Characteristics:
      - Monitors memory access at runtime
      - Provides precise stack traces
      - Has performance overhead (~2–3x)

  - **UndefinedBehaviorSanitizer (UBSan)**: Detects undefined behavior in C++  
    - Detectable issues:
      - Integer overflow
      - Invalid casts
      - Null pointer dereference
      - Out-of-bounds access
      - Misaligned memory access
      - Invalid enum values
    - Characteristics:
      - Effective for detecting logic errors
      - Lighter than ASan
      - Can warn before crash

---

<br />

- **setup_core_dump_systemwide.sh**  
  - Configures the system to generate core dump files globally (requires sudo).
  ```bash
  sudo ./setup_core_dump_systemwide.sh
  ```
  - Core file name pattern: `core.<exe>.<pid>.<time>`
    - `<exe>` : executable name  
    - `<pid>` : process ID  
    - `<time>` : epoch time  
      - Convert with:
        ```bash
        date -d @<time> '+%Y-%m-%d %H:%M:%S %Z'
        ```

---

<br />

- **run_hello_with_core.sh**  
  - Executes the hello program and generates a core dump.
  - Requires system-wide core dump configuration.
  - Set executable path before use:
  ```bash
  WORKDIR="/home/jaytwo/workspace/coredump-workspace"
  EXEC="${WORKDIR}/hello"
  ```

---

<br />

- **run_hello_with_core_daemon.sh**  
  - Runs the hello program repeatedly in daemon mode.
    - Automatically restarts on exit
    - Enables core dumps and ASAN/UBSAN
    - Log file is rotated when exceeding 10MB (keeps last 10,000 lines)
    ```bash
    MAX_LOG_SIZE=10485760 # 10MB
    MAX_LOG_LINES=10000
    if [ -f "${LOG}" ] && [ $(stat -c%s "${LOG}") -ge $MAX_LOG_SIZE ]; then
        tail -n $MAX_LOG_LINES "${LOG}" > "${LOG}.tmp" && mv "${LOG}.tmp" "${LOG}"
        echo "[$(date '+%F %T')] log trimmed to last $MAX_LOG_LINES lines" >> "${LOG}"
    fi
    ```
  - Configure executable path:
    ```bash
    WORKDIR="/home/jaytwo/workspace/coredump-workspace"
    EXEC="${WORKDIR}/hello"
    ```

---

<br />

- **gdb_hello_core.sh**  
  - Script to analyze core dump using gdb.
  ```bash
  ./gdb_hello_core.sh <core_dump_file>
  ```
  - Set executable path:
  ```bash
  WORKDIR="/home/jaytwo/workspace/coredump-workspace"
  EXEC="${WORKDIR}/hello"
  ```

---

<br />

- **list_core_with_time.sh**  
  - Lists core files in the current directory with human-readable timestamps.

---

<br />

## Usage Example

1. Configure core dump system  
   ```bash
   sudo ./setup_core_dump_systemwide.sh
   ```

2. Build executable with debug symbols  
   ```bash
   g++ -g -O0 -Wall -Wextra -o hello main.cpp
   ```

3. Generate core dump  
   ```bash
   ./run_hello_with_core.sh
   ```

4. List core dump files  
   ```bash
   ./list_core_with_time.sh
   ```

5. Analyze core dump  
   ```bash
   ./gdb_hello_core.sh core.hello.<pid>.<time>
   ```
   - gdb commands:
     - `r` : run
     - `bt full` : full backtrace with local variables
     - `list` : show source lines

6. Run as daemon  
   ```bash
   ./run_hello_with_core_daemon.sh
   ```

---

## Automatic Startup Setup
- Installation guide: [INSTALL.md](INSTALL.md)
