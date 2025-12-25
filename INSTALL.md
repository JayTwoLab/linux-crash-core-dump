
# 리눅스 부팅 직후 자동 실행 <sub> (로그인 없이) </sub>

- bash 로그인 여부와 무관하게, 리눅스가 부팅되자마자 자동 실행되게 하려면 반드시 `systemd system` 서비스로 등록해야 합니다.

<br />

---

## 1. 왜 다른 방법들은 안 되는가?

| 방법                  | 로그인 필요         | 부팅 직후 자동 |
| --------------------- | ------------------- | -------------- |
| nohup, disown         | 필요                | 불가능         |
| systemd --user        | 필요 (linger 필요)  | 제한적         |
| systemd system 서비스 | 불필요              | 가능           |

- nohup, tmux, screen 방식은 터미널 또는 로그인 세션을 전제로 합니다.
- systemd --user 방식은 사용자 세션에 의존합니다.
- systemd system 서비스만이 로그인 없이 부팅 시 자동 실행됩니다.

---

## 2. 정석 구성 방법

### 2.1. systemd system 서비스 파일 생성 (root)

- 다음과 같이 서비스 파일 생성 
   - `sudo vim /etc/systemd/system/hello-core.service`

- `system/hello-core.service` 파일
```ini
[Unit]
Description=hello daemon (core dump enabled)
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/jaytwo/workspace
ExecStart=/home/jaytwo/workspace/hello

Restart=always
RestartSec=1

LimitCORE=infinity

User=jaytwo
Group=jaytwo

[Install]
WantedBy=multi-user.target
```

<br />

---

### 2.2. 서비스 등록 및 실행 (root, 1회)

```bash
sudo systemctl daemon-reload
sudo systemctl enable hello-core.service
sudo systemctl start hello-core.service
```

- `sudo systemctl daemon-reload` : 디스크에서 다시 읽어 메모리에 반영
- `sudo systemctl enable hello-core.service` : 부팅 시 자동으로 `hello-core.service`가 시작되도록 등록
- `sudo systemctl start hello-core.service` : `hello-core.service` 시작 (정지는 stop)

<br />

- 상태 확인:

```bash
systemctl status hello-core.service
```
<br />

- 로그 확인:

```bash
journalctl -u hello-core.service -f
```

<br />

---

## 3. core dump가 생성되기 위한 필수 조건

1. 커널 설정

   ```bash
   cat /proc/sys/kernel/core_pattern
   ```

   예: `core.%e.%p.%t`

2. 실행 디렉터리 쓰기 권한
   `/home/jaytwo/workspace`

3. core size 제한 해제
   systemd 서비스 설정의 `LimitCORE=infinity`

---

## 4. 전체 흐름 요약

```
리눅스 부팅
 → kernel
 → systemd (PID 1)
     → hello-core.service 실행
         → hello 크래시 시 core dump 생성
```

로그인, bash, SSH는 필요하지 않습니다.

---

## 5. 요약

부팅 후 로그인하지 않아도 자동 실행되게 하려면
systemd system 서비스로 등록하는 것이 유일하고 정석적인 방법입니다.


