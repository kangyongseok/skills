# Claude Code Skills

이직해도 그대로 들고 다니는 **포터블 개발환경 자산** 저장소입니다. Claude Code 스킬·에이전트·커맨드에 더해, **터미널 설정(zsh)·git alias·에디터(VSCode/Cursor) 확장 목록**까지 한곳에서 관리하고, `bootstrap.sh` 한 번으로 새 머신을 전부 세팅합니다.

- **내 스킬/에이전트/커맨드**는 실제 파일(`skills/`, `agents/`, `commands/`)로 포함되고 `install.sh`가 `~/.claude`에 심링크합니다.
- **dotfiles / git alias / 에디터 확장**은 `dotfiles/`, `git/`, `editors/`에 포함되고 `bootstrap.sh`가 적용합니다.
- **서드파티 스킬**은 라이선스·저작권 존중을 위해 파일을 복제하지 않고, 아래 표에 설명과 **다운로드 출처(원본 저장소)** 만 정리했습니다.
- **회사 관련 정보·비밀은 일절 포함하지 않습니다.** 토큰·개인 도메인은 커밋되지 않는 `~/.secrets.zsh`로 분리되며, git 개인 식별정보(user.name/email)도 공유 파일에 넣지 않습니다. 공개 저장소로 유지해도 안전합니다.

## 한 번에 세팅 (bootstrap)

```bash
git clone https://github.com/kangyongseok/skills.git ~/fe-agent-pack
cd ~/fe-agent-pack
./bootstrap.sh          # dotfiles + git alias + 에디터 확장 + Claude 자산 전부 세팅
```

`bootstrap.sh`가 순서대로 수행하는 일:
1. **dotfiles(zsh)** — `~/.zshrc`·`~/.zprofile`·`~/.p10k.zsh` 심링크 (기존 파일은 `~/.dotfiles-backup-*`로 백업). `~/.secrets.zsh` 템플릿 생성.
2. **git alias + color** — `git config --global include.path`로 `git/aliases.gitconfig` 연결.
3. **에디터 확장** — `editors/{vscode,cursor}-extensions.txt`를 `code`/`cursor` CLI로 설치(CLI 없으면 건너뜀).
4. **Claude 자산** — `install.sh` 실행.

Claude 자산만 따로 설치하려면:

```bash
./install.sh                     # ~/.claude/{skills,agents,commands}에 멱등 심링크
./uninstall.sh                   # 이 저장소로 향한 링크만 제거
CLAUDE_HOME=/custom ./install.sh # 커스텀 설정 디렉터리 대상
```

- **모델 중립** — 어떤 자산에도 `model:` 하드코딩 없음. 다음 직장의 모델 정책(fable/sonnet/opus …)과 무관하게 작동.
- **안전·멱등** — 무관한 파일·심링크는 건드리지 않고, 재실행은 no-op이며, 교체 대상은 백업 후 진행.

> `skills/` 아래 서드파티/npm 래퍼 스킬(`react-doctor` 등)도 `install.sh` 대상이 되지만, 이미 실제 디렉터리로 설치돼 있으면 건너뜁니다.

### 첫 로그인 시 시크릿 채우기

```bash
$EDITOR ~/.secrets.zsh   # SLACK_BOT_TOKEN, VERCEL_BETA_ALIAS 등 머신-로컬 값 입력
exec zsh                 # 셸 리로드
```

---

## 1. 내 스킬 (이 저장소에 포함)

| 스킬 | 설명 | 출처 / 다운로드 |
|------|------|-----------------|
| [`fe-anti-pattern-guard`](skills/fe-anti-pattern-guard/) | React/프론트엔드 컴포넌트 작성·수정·리뷰 시 자동 점검하는 안티패턴 가드레일. Props drilling(→ TanStack Query 캐시), 중첩 삼항, God file, `useMemo`/`useCallback`/`useEffect` 과사용, 콜로케이션, Rule of Three, 레거시/중복 코드 표시 등 9개 규칙. | 직접 제작 (개인). 이 저장소 `skills/fe-anti-pattern-guard/` |
| [`react-doctor`](skills/react-doctor/) | React 코드베이스의 보안·성능·정확성·아키텍처 이슈를 스캔해 0~100점 진단 리포트를 출력. React 변경 직후 실행해 조기 점검. | npm 패키지 `react-doctor` 래퍼 — `npx -y react-doctor@latest . --verbose --diff`. 이 저장소 `skills/react-doctor/` |
| [`fe-review-checklist`](skills/fe-review-checklist/) | 시니어 FE의 개인 PR 리뷰 **워크플로우** — 트리아지 순서, 심각도 라벨(`[block]`/`[should]`/`[nit]`/`[question]`), 차단 기준. 범용 안티패턴 나열이 아닌 "리뷰 행위" 자체를 인코딩. | 직접 제작 (개인, fe-agent-pack). 이 저장소 `skills/fe-review-checklist/` |
| [`fe-scaffold`](skills/fe-scaffold/) | 개인 컨벤션(폴더 콜로케이션·네이밍·테스트·loading/empty/error 상태 기본값)으로 컴포넌트/기능 스캐폴딩. 레포 스택 감지 후 매칭. | 직접 제작 (개인, fe-agent-pack). 이 저장소 `skills/fe-scaffold/` |

### 복원 완료 (2026-07-06)

개인 FE 에이전트 팩(`~/fe-agent-pack`) 삭제로 심링크가 깨져 제거됐던 `fe-review-checklist`·`fe-scaffold`를 **원본 재작성(모델 중립)으로 복원**하고, 이 저장소를 정식 원본 소스로 통합했습니다. 더 이상 별도 로컬 팩에 의존하지 않습니다.

## 1-2. 내 에이전트 / 커맨드 (이 저장소에 포함)

| 자산 | 유형 | 설명 | 위치 |
|------|------|------|------|
| `fe-onboarder` | agent | 낯선 프론트엔드 레포를 읽기 전용으로 매핑 → 스택·진입점·라우팅·상태·데이터플로우·리스크를 담은 `ORIENTATION.md` 생성. 이직 첫날/신규 레포 파악용. 소스 불변. | `agents/fe-onboarder.md` |
| `/fe-audit` | command | 현재 프론트엔드 프로젝트의 접근성 + 성능(Core Web Vitals) 빠른 감사. 심각도별·구체적 수정안 리포트. | `commands/fe-audit.md` |

> 각 자산에는 `TODO(personalize)` 마커가 있어, 본인 스택·리뷰 취향·컨벤션을 주입하면 진짜 개인 자산이 됩니다.

---

## 2. 서드파티 스킬 (다운로드 출처 정리)

`~/.agents/.skill-lock.json`에 기록된 설치 출처 기준입니다. `sourceUrl` + `skillPath`로 원본을 찾을 수 있습니다.

| 스킬 | 설명 | 다운로드 (원본 저장소) | 라이선스 |
|------|------|------------------------|----------|
| `vercel-react-best-practices` | Vercel 엔지니어링의 React/Next.js 성능 최적화 가이드라인. 컴포넌트·데이터 페칭·번들 최적화 작업 시 트리거. | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) · `skills/react-best-practices/` | MIT |
| `find-skills` | 필요한 기능이 스킬로 존재하는지 탐색·설치를 돕는 메타 스킬. | [vercel-labs/skills](https://github.com/vercel-labs/skills) · `skills/find-skills/` | 원본 확인 |
| `requesting-code-review` | 작업 완료·주요 기능 구현·머지 전 요구사항 충족 여부를 검증하는 코드 리뷰 요청 워크플로우. | [obra/superpowers](https://github.com/obra/superpowers) · `skills/requesting-code-review/` | 원본 확인 |
| `webapp-testing` | Playwright로 로컬 웹앱을 조작·테스트. 프론트엔드 검증, UI 디버깅, 스크린샷/콘솔 로그 캡처. | [anthropics/skills](https://github.com/anthropics/skills) · `skills/webapp-testing/` | Apache-2.0 |
| `modern-web-guidance` | 최신 웹 개발 베스트 프랙티스 검색 도구(뷰 트랜지션, 컨테이너 쿼리, `:has()`, CWV 등). HTML/CSS/클라이언트 JS 작업 시 우선 실행. | [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance) · `skills/modern-web-guidance/` | 원본 확인 |
| `ask-docs` | CrewAI 공식 문서 질의. API 세부·설정·고급 기능·트러블슈팅 등 최신 문서가 필요할 때. | [crewaiinc/skills](https://github.com/crewaiinc/skills) · `skills/ask-docs/` | 원본 확인 |
| `design-agent` | CrewAI 에이전트 설계·설정(role/goal/backstory, LLM 선택, 툴 할당, `max_iter` 튜닝, 가드레일 등). | [crewaiinc/skills](https://github.com/crewaiinc/skills) · `skills/design-agent/` | 원본 확인 |
| `design-task` | CrewAI 태스크 설계·설정(description/expected_output, context 의존성, 출력 포맷, 가드레일 검증 등). | [crewaiinc/skills](https://github.com/crewaiinc/skills) · `skills/design-task/` | 원본 확인 |
| `getting-started` | CrewAI 아키텍처 결정·프로젝트 스캐폴딩(LLM.call vs Agent vs Crew vs Flow, YAML 설정, `@CrewBase`, Flow `@start`/`@listen`). | [crewaiinc/skills](https://github.com/crewaiinc/skills) · `skills/getting-started/` | 원본 확인 |

### 설치 방법 (서드파티)

Vercel의 [skills CLI](https://github.com/vercel-labs/skills)를 사용해 설치된 스킬들입니다. 재설치 예시:

```bash
# 예: anthropics/skills 의 webapp-testing 설치
npx skills add anthropics/skills/webapp-testing

# 예: crewaiinc/skills 의 getting-started 설치
npx skills add crewaiinc/skills/getting-started
```

> 정확한 CLI 명령은 각 원본 저장소 README를 확인하세요. 이 목록은 `~/.agents/.skill-lock.json` 설치 기록을 기준으로 작성했습니다.

---

## 3. 플러그인 번들 스킬

마켓플레이스 플러그인을 통해 함께 설치되는 스킬입니다(개별 다운로드 대상 아님).

| 스킬 | 설명 | 소속 플러그인 / 마켓플레이스 |
|------|------|------------------------------|
| `omc-reference` | OMC 에이전트 카탈로그·툴·팀 파이프라인 라우팅·커밋 프로토콜·스킬 레지스트리 참조. (내부용, `user-invocable: false`) | oh-my-claudecode → [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) |

### 참고: 설치된 마켓플레이스

| 마켓플레이스 | 저장소 |
|--------------|--------|
| claude-plugins-official | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) |
| addy-agent-skills | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |
| claude-hud | [jarrodwatts/claude-hud](https://github.com/jarrodwatts/claude-hud) |
| omc | [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) |

---

## 저장소 구조

| 경로 | 내용 |
|------|------|
| `skills/<name>/SKILL.md` | 내 스킬 (실제 파일, `install.sh`로 심링크) |
| `agents/<name>.md` | 내 에이전트 |
| `commands/<name>.md` | 내 슬래시 커맨드 |
| `dotfiles/` | zsh 설정(`zshrc`·`zprofile`·`p10k.zsh`) + `secrets.zsh.example` 템플릿 |
| `git/aliases.gitconfig` | git alias + color (개인 식별정보 제외) |
| `editors/*.txt` | VSCode·Cursor 확장 ID 목록 |
| `bootstrap.sh` | 전체 환경 한 번에 세팅 |
| `install.sh` / `uninstall.sh` | Claude 자산 멱등 심링크 설치/제거 (모델 중립·회사 중립) |

개선 백로그(AI 에이전트 실행용 태스크 스펙): [docs/ROADMAP.md](docs/ROADMAP.md)

## 스킬 설치 위치 참고

| 경로 | 용도 |
|------|------|
| `~/.claude/skills/` | Claude Code 글로벌 스킬 (심링크 포함) |
| `~/.agents/skills/` | 크로스 에이전트 스킬 설치 소스 (`vercel-labs/skills` CLI 관리) |
| `~/.agents/.skill-lock.json` | 서드파티 스킬 설치 출처 잠금 파일 |
| `~/.claude/plugins/` | 마켓플레이스 플러그인 (번들 스킬 포함) |

*문서 작성 기준일: 2026-07-06*
