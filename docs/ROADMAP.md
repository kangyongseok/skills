# 개선 로드맵 (Opus 실행용 태스크 스펙)

이 문서는 이 저장소(포터블 FE 개발환경 자산 팩)의 **검토 결과**와 **개선 백로그**를,
AI 에이전트(Opus 등)가 태스크 단위로 그대로 실행할 수 있는 스펙 형식으로 정리한 것입니다.

> 작성 기준일: 2026-07-06 · 검토 도구: Claude Code (격리 HOME 스모크 테스트 포함)

---

## 실행 방법 (Opus 세션에서)

1. **태스크 1개 = 프롬프트 1개.** 예: "docs/ROADMAP.md의 P0-1을 실행해줘".
2. 각 태스크 완료 시 반드시: (a) 해당 태스크의 **수용 기준** 전부 검증 → (b) 아래 **공통 하드 게이트** 통과 확인 → (c) 단독 커밋.
3. 순서: P0 → P1 → P2. P0-1·P0-2(가드)가 먼저 깔려야 이후 태스크의 실수를 자동으로 잡는다.
4. `사용자 입력 필요` 표시가 있는 태스크는 AskUserQuestion 등으로 먼저 인터뷰하고 진행한다.

## 공통 하드 게이트 (모든 태스크 완료 조건)

| # | 게이트 | 검증 방법 |
|---|--------|-----------|
| G1 | **공개 안전** — 회사 정보(사명·제품명·내부 도메인·이메일)·실제 토큰 커밋 0건 | `scripts/check-sanitized.sh` (P0-2에서 생성) 실행 exit 0. **차단 키워드 패턴 자체도 공개 레포에 커밋하지 않는다** — 로컬은 git-ignore된 `~/.repo-guard-patterns` 파일, CI는 GitHub Actions secret `GUARD_PATTERNS`로 주입. (패턴을 평문 커밋하면 그 자체가 회사 키워드 노출이 되기 때문) |
| G2 | **모델 중립** — `skills/ agents/ commands/` 파일에 `model:` frontmatter 금지 | `grep -rE '^model:' skills agents commands` 결과 0건 |
| G3 | **실환경 무손상** — 사용자의 실제 `~/.zshrc`·`~/.gitconfig`·에디터 설정을 저장소 작업이 변경하지 않음. 적용은 새 머신 bootstrap 시에만 + 타임스탬프 백업 | 작업 전후 `[ ! -L ~/.zshrc ]`, `git config --global --get include.path` 불변 확인 |
| G4 | **멱등** — 모든 설치 스크립트 재실행 안전 | 격리 HOME 스모크: `HOME=<scratch> SKIP_EDITOR_EXT=1 SKIP_BREW=1 ./bootstrap.sh` 2회 연속 실행, 2회차 전부 no-op |

---

## 현재 자산 검토 요약 (2026-07-06 기준)

| 영역 | 상태 | 평가 |
|------|------|------|
| Claude 자산 (skills 4 · agent 1 · command 1) | 모델 중립, 심링크 설치 검증됨 | 양호 — `TODO(personalize)` 5개 파일 미기입 (→ P2-1) |
| dotfiles (zshrc·zprofile·p10k) + `~/.secrets.zsh` 분리 | 정화·격리 테스트 통과 | 양호 |
| git alias 28종 (`include.path` 방식, 개인 식별정보 제외) | 적용 검증됨 | 양호 |
| 에디터 확장 목록 (VSCode 21 · Cursor 39) | 목록만 캡처 | settings/keybindings 미캡처 (→ P1-1) |
| bootstrap.sh 원샷 세팅 | 격리 HOME 테스트 통과 | 선행도구(brew·oh-my-zsh·p10k·bun) 설치 단계 없음 (→ P0-3) |
| 보안 | 수동 grep 스캔만 | CI 가드 없음 — 과거 로컬 셸 설정에서 실서비스 토큰이 발견된 이력이 있어 자동화 필수 (→ P0-1, P0-2) |
| 유지보수 | 확장 목록 재추출이 수동 | 재캡처 자동화 없음 (→ P1-2) |

---

# P0 — 안전·재현성 (최우선)

## P0-1. CI 가드: 시크릿·회사정보·모델핀 자동 차단

- **목표**: push/PR마다 시크릿·회사 키워드·모델 하드코딩을 자동 차단해 공개 저장소의 신뢰를 기계적으로 보장한다.
- **생성 파일**: `.github/workflows/guard.yml`
- **구현 단계**:
  1. push·pull_request 트리거 워크플로우 작성. 잡 3개:
     - `gitleaks`: `gitleaks/gitleaks-action@v2` (기본 룰로 토큰류 탐지)
     - `company-scan`: 저장소 secret `GUARD_PATTERNS`(ERE 한 줄)를 받아 `grep -rniE "$GUARD_PATTERNS" --exclude-dir=.git .` 히트 시 fail. secret 미설정 시 경고만 하고 통과(포크 안전).
     - `model-neutral`: `grep -rE '^model:' skills agents commands` 히트 시 fail
  2. `dotfiles/secrets.zsh.example`의 예시 플레이스홀더가 걸리지 않도록 gitleaks allowlist 또는 해당 파일 제외 설정.
  3. 저장소 Settings → Secrets에 `GUARD_PATTERNS` 등록 안내를 README 유지보수 절에 1줄 추가 (패턴 값 자체는 문서에 쓰지 않는다 — G1).
- **안전 게이트**: 워크플로우 파일 자체에 회사 키워드·패턴 평문 금지 (G1).
- **수용 기준**:
  - [ ] push 후 Actions에서 3개 잡 모두 그린
  - [ ] 로컬에서 차단 키워드를 임시 파일에 주입하고 company-scan과 동일한 grep을 돌리면 비-0 exit (임시 파일은 즉시 삭제, 커밋 금지)
- **사용자 입력**: `GUARD_PATTERNS` secret 등록은 사용자가 GitHub UI에서 수행 (값 안내는 로컬에서만).

## P0-2. 로컬 스캔 스크립트 + 저장소-로컬 pre-push 훅

- **목표**: 커밋·push 전에 로컬에서 같은 게이트를 돌려 CI 이전에 잡는다.
- **생성 파일**: `scripts/check-sanitized.sh`, `githooks/pre-push` / **수정**: `bootstrap.sh`, `.gitignore`(필요 시)
- **구현 단계**:
  1. `check-sanitized.sh`: (a) `~/.repo-guard-patterns` 존재 시 그 패턴으로 grep 스캔, 없으면 "패턴 파일 없음 — 기본 검사만" 경고 (b) 모델핀 검사 (c) `git ls-files`에 `.omc/`·`.secrets` 계열 혼입 검사. 실패 시 exit 1.
  2. `githooks/pre-push`: `exec "$(git rev-parse --show-toplevel)/scripts/check-sanitized.sh"`
  3. `bootstrap.sh`에 `git config core.hooksPath githooks` 추가 — **이 저장소 클론에만 적용**(`git -C "$REPO_DIR"`), 전역 아님 (G3).
  4. `~/.repo-guard-patterns` 템플릿 안내를 `dotfiles/secrets.zsh.example`과 같은 방식의 예시 파일(`scripts/repo-guard-patterns.example`)로 제공 — 예시에는 일반 패턴(`xox[a-z]-[0-9]`, `ghp_[A-Za-z0-9]{20,}` 등)만, 회사 키워드는 미포함.
- **수용 기준**:
  - [ ] `./scripts/check-sanitized.sh` exit 0
  - [ ] 오염 임시 주입 시 exit 1 (주입물 즉시 삭제)
  - [ ] `git config core.hooksPath`가 전역이 아닌 저장소 로컬에만 설정됨
  - [ ] G4 격리 스모크 통과

## P0-3. Brewfile + 선행조건 자동 설치 (bootstrap step 0)

- **목표**: dotfiles가 참조하는 도구들이 새 머신에서 자동 설치되게 해 "원샷 세팅"을 진짜로 만든다.
- **생성 파일**: `Brewfile` / **수정**: `bootstrap.sh`, `docs/SETUP.md`
- **구현 단계**:
  1. `Brewfile` 작성(전체 덤프가 아닌 dotfiles 의존성 + 핵심 도구 선별):
     - tap: `romkatv/powerlevel10k`
     - formula: `git`, `gh`, `git-flow-avh`, `git-lfs`, `nvm`, `pnpm`, `neovim`, `zsh-autosuggestions`, `powerlevel10k`
     - cask: `claude-code` (필요 시 추가 GUI 앱은 사용자와 상의 후)
  2. `bootstrap.sh` step 0 추가 (`SKIP_BREW=1`로 생략 가능):
     - brew 미설치 시 안내만 하고 skip (자동 설치는 sudo 필요해 명시적 안내가 안전)
     - `brew bundle check --file Brewfile || brew bundle --file Brewfile`
     - oh-my-zsh 미설치 시 `RUNZSH=no CHSH=no KEEP_ZSHRC=yes` 비대화식 설치
     - bun 미설치 시 공식 설치 스크립트 (`[ -d ~/.bun ] ||` 멱등 체크)
  3. zshrc의 zsh-autosuggestions source 경로가 brew prefix에 따라 다른 문제(`/usr/local` vs `/opt/homebrew`) — 두 경로 모두 시도하도록 dotfiles/zshrc 보강.
  4. `docs/SETUP.md`에 step 0 반영.
- **안전 게이트**: 실환경에서 brew install 실행 금지 — 검증은 `bash -n` + 격리 HOME + `SKIP_BREW=1` 경로만 (G3). Brewfile 유효성은 `brew bundle check --file Brewfile`(읽기 전용)로만.
- **수용 기준**:
  - [ ] `bash -n bootstrap.sh` 통과
  - [ ] `SKIP_BREW=1` 격리 스모크에서 기존 4단계 플로우 무손상
  - [ ] 실환경 brew 목록 변경 없음 (`brew list | wc -l` 전후 동일)

## P0-4. CI 스모크 테스트: bootstrap 회귀 방지

- **목표**: 이번 세션에서 수동으로 한 격리 HOME 테스트를 CI로 옮겨 설치 스크립트 회귀를 자동 탐지.
- **생성 파일**: `.github/workflows/smoke.yml`
- **구현 단계**:
  1. `macos-latest` 러너, 단계:
     - `export HOME=$RUNNER_TEMP/fakehome && mkdir -p $HOME`
     - `SKIP_EDITOR_EXT=1 SKIP_BREW=1 ./bootstrap.sh`
     - 검증 스텝: `readlink $HOME/.zshrc` 가 레포 내부를 가리킴 · `$HOME/.secrets.zsh` 존재 · `git config --file $HOME/.gitconfig --get include.path` 매칭 · `$HOME/.claude/skills` 링크 수 ≥ 4
     - 같은 명령 2회차 실행 → 출력에 `+`(신규 링크) 없음(멱등 확인)
  2. ubuntu 러너 추가는 선택(경로 차이로 가치 낮음 — macOS만으로 충분).
- **수용 기준**: [ ] push 후 Actions 그린 [ ] 멱등 검증 스텝 포함

---

# P1 — 캡처 확장

## P1-1. 에디터 설정(settings/keybindings) 캡처 — 정화 필수

- **목표**: 확장 목록만이 아니라 에디터 동작 설정까지 들고 다닌다.
- **생성 파일**: `editors/settings/vscode-settings.json`, `editors/settings/cursor-settings.json`, `editors/settings/cursor-keybindings.json` / **수정**: `bootstrap.sh`, `docs/SETUP.md`
- **구현 단계**:
  1. 원본 위치에서 복사:
     - VSCode: `~/Library/Application Support/Code/User/settings.json`
     - Cursor: `~/Library/Application Support/Cursor/User/{settings.json,keybindings.json}`
  2. **정화**: Cursor settings.json에서 회사 GitHub Enterprise 주소가 담긴 키(`github-enterprise` 계열)와 그 외 사내 URL·계정 흔적 키를 제거. jq로 키 삭제 후 결과에 대해 스캔 실행.
  3. `bootstrap.sh` step 3에 적용 로직: 대상 파일 존재 시 타임스탬프 백업(`link_dotfile`의 백업 로직 재사용) 후 **복사**(심링크 아님 — 에디터가 설정을 자주 rewrite하므로 저장소 오염 방지). `SKIP_EDITOR_EXT=1`이면 함께 skip.
  4. `docs/SETUP.md` 카탈로그에 반영.
- **수용 기준**:
  - [ ] 캡처본 3개 파일에 회사 문자열·URL 0건 (`check-sanitized.sh` + 수동 확인)
  - [ ] 격리 HOME에서 복사·백업 동작
  - [ ] 실환경 에디터 설정 파일 mtime 무변경 (G3)

## P1-2. 환경 재캡처 자동화 `scripts/sync-env.sh`

- **목표**: "환경이 바뀌면 스크립트 하나 돌리고 커밋"이라는 유지보수 루프를 만든다.
- **생성 파일**: `scripts/sync-env.sh` / **수정**: `README.md`, `docs/SETUP.md`
- **구현 단계**:
  1. 확장 목록 재추출(이번 세션의 수동 파이프라인을 스크립트화):
     `ls ~/.vscode/extensions | grep -vE '^\.|^extensions\.json$' | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+.*$//' | sort -u > editors/vscode-extensions.txt` (Cursor 동일)
  2. 에디터 settings 재복사 + **정화 필터 내장**: 제거 대상 키 목록(jq `del(...)`)을 스크립트 상수로 관리 — 키 이름은 일반 명칭(`github-enterprise` 등 설정 키)이므로 커밋 가능, 값은 절대 커밋 안 됨.
  3. 종료 시 `scripts/check-sanitized.sh` 자동 실행 — 실패하면 변경사항 목록을 보여주고 비-0 exit.
  4. `git status --short` 요약 출력으로 커밋할 변경을 안내.
- **수용 기준**:
  - [ ] 환경 무변경 상태에서 실행 시 diff 0 (멱등)
  - [ ] 정화 필터가 회사 키를 실제로 제거함 (제거 전후 jq 키 비교)
  - [ ] 마지막에 check-sanitized 자동 실행됨

## P1-3. Claude Code 개인 설정 캡처 (model 키 제외)

- **목표**: statusLine·언어·권한 등 Claude Code UX 설정을 새 머신에 복원.
- **생성 파일**: `claude/settings.example.json` / **수정**: `bootstrap.sh`, `docs/SETUP.md`
- **구현 단계**:
  1. `~/.claude/settings.json`에서 **`model` 키 제외**(이 저장소의 모델 중립 원칙 — 다음 직장의 모델 정책을 따르게 함), 머신·세션 종속 키 제외한 정화본 생성.
  2. `bootstrap.sh`: `~/.claude/settings.json`이 **없을 때만** 복사 — 기존 설정 절대 덮어쓰지 않음(병합 시도 금지, 단순함 우선).
  3. `docs/SETUP.md` 반영.
- **수용 기준**:
  - [ ] 캡처본에 `model` 키 없음, 회사 문자열 0건
  - [ ] 격리 HOME에서 신규 생성 확인, 기존 파일 존재 시 no-op
  - [ ] 실환경 `~/.claude/settings.json` 무변경 (G3)

---

# P2 — 자산 확장·위생 (사용자 입력/승인 필요)

## P2-1. `TODO(personalize)` 개인화 인터뷰 `[사용자 입력 필수]`

- **목표**: 템플릿 상태인 5개 자산(fe-onboarder·fe-review-checklist·fe-scaffold·fe-audit·README)에 사용자의 실제 취향을 주입해 "진짜 내 자산"으로 만든다.
- **구현 단계**: AskUserQuestion 기반 짧은 인터뷰(자산당 2~3문항) → 답을 각 파일의 `TODO(personalize)` 블록에 반영:
  - fe-review-checklist: 차단 기준의 개인 강도(barrel file·테스트 철학·CSS 접근), "내가 항상 잡는 것" 목록
  - fe-scaffold: 실제 선호 스타일링 라이브러리·테스트 스타일·barrel/story 파일 여부
  - fe-onboarder: 입사 첫날 반드시 묻는 질문 목록
  - fe-audit: 유지하는 성능 예산(LCP·번들 크기)·a11y 기준(WCAG 레벨)
- **수용 기준**: [ ] 5개 파일에서 `TODO(personalize)` 마커 소멸 [ ] 내용에 회사 고유 정보 미포함(G1) — 취향은 개인 자산, 회사 규칙은 배제

## P2-2. `fe-debug-playbook` skill 신설

- **목표**: 증상→재현→국소화→수정→가드레일로 이어지는 개인 FE 디버깅 순서를 자산화 (초기 기획 시 후보였던 항목).
- **생성 파일**: `skills/fe-debug-playbook/SKILL.md`
- **구현 단계**: 기존 스킬과 겹치지 않게 "개인 프로세스"만: 브라우저 우선 확인 순서(콘솔→네트워크→리렌더 프로파일), 이분탐색 국소화 습관, 수정 후 회귀 가드(테스트/스토리) 규칙. frontmatter는 name+description만(G2). `install.sh`는 자동 인식(디렉터리 글롭)이므로 수정 불요.
- **수용 기준**: [ ] `./install.sh` 재실행 시 신규 링크 1건 추가 [ ] G1·G2 통과

## P2-3. ADR 인터뷰어 agent 신설

- **목표**: 기술 선택 시 근거·대안·트레이드오프를 끌어내 ADR 문서로 남기는 에이전트.
- **생성 파일**: `agents/adr-interviewer.md`
- **구현 단계**: read-only + Write(ADR 파일만) 도구 구성. 출력 형식: Context/Decision/Drivers/Alternatives/Consequences. 질문 스타일은 한 번에 하나, 트레이드오프 중심.
- **수용 기준**: [ ] install 후 agent 목록에 노출 [ ] 샘플 주제로 1회 실행해 ADR 마크다운 산출 확인

## P2-4. 로컬 위생 가이드 (저장소 외 작업, 옵트인) `[사용자 승인 필수]`

- **목표**: 저장소 밖 실제 환경의 보안 부채를 정리한다. **이 태스크만은 실환경을 변경하므로 각 단계마다 사용자 확인 후 진행.**
- **구현 단계** (문서로는 절차만, 실행은 승인 후):
  1. **노출 토큰 폐기**: 과거 셸 설정에 평문 저장돼 있던 메신저 봇 토큰을 서비스 관리 콘솔에서 rotate → 새 토큰은 `~/.secrets.zsh`에만 저장.
  2. **실제 `~/.zshrc` 전환**: 백업 후 저장소의 정화본 구조(시크릿 분리)로 마이그레이션 — 토큰·사내 배포 함수는 `~/.secrets.zsh`로 이동.
  3. **push 계정 정리**: 현재 회사 GitHub 계정으로 push되고 있음 → 개인 계정 credential로 전환(`gh auth login` 또는 remote별 credential 설정). 개인 자산 저장소는 개인 계정으로 관리하는 것이 이직 시 접근 연속성 측면에서 안전.
- **수용 기준**: [ ] 구 토큰 무효화 확인 [ ] `grep`으로 실제 zshrc에 토큰 평문 0건 [ ] `git log`의 신규 커밋 author가 개인 계정

## P2-5. macOS defaults 스크립트 (선택)

- **목표**: 키 반복 속도·Dock 등 OS 선호 설정 자동화.
- **생성 파일**: `scripts/macos-defaults.sh` (bootstrap에는 연결하지 않고 수동 실행 — OS 설정은 침습적이므로)
- **수용 기준**: [ ] 스크립트 상단에 각 defaults 항목 주석 설명 [ ] 실행 전 현재 값 출력(되돌리기 참고용)

---

## 우선순위 요약

| 순위 | 태스크 | 가치 | 노력 |
|------|--------|------|------|
| 1 | P0-1 + P0-2 (가드) | 공개 저장소 신뢰 기반 — 사고 재발 방지 | 소 |
| 2 | P0-3 (Brewfile) | "원샷 세팅" 완성 — 이직 첫날 체감 최대 | 소~중 |
| 3 | P0-4 (CI 스모크) | 설치 스크립트 장기 신뢰 | 소 |
| 4 | P1-1 + P1-2 (에디터 설정 + sync 자동화) | 유지보수 루프 확립 | 중 |
| 5 | P1-3 (Claude 설정) | UX 복원 | 소 |
| 6 | P2-1 (개인화) | 자산의 본질 가치 — 인터뷰 필요 | 중 |
| 7 | P2-4 (로컬 위생) | 보안 부채 정리 — 별도 승인 | 소 |
| 8 | P2-2 · P2-3 · P2-5 | 자산 확장 | 중 |
