# Claude Code Skills

내 로컬·글로벌 환경(`~/.claude/skills`)에 설치된 [Claude Code Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) 모음과 각 스킬의 설명·다운로드 출처를 정리한 저장소입니다.

- **내 스킬**은 이 저장소에 실제 파일(`skills/`)로 포함되어 있습니다.
- **서드파티 스킬**은 라이선스·저작권 존중을 위해 파일을 복제하지 않고, 아래 표에 설명과 **다운로드 출처(원본 저장소)** 만 정리했습니다.
- 출처 근거: `~/.agents/.skill-lock.json`(설치 기록), `~/.claude/plugins/known_marketplaces.json`(플러그인 마켓플레이스). 기준일 2026-07-06.

---

## 1. 내 스킬 (이 저장소에 포함)

| 스킬 | 설명 | 출처 / 다운로드 |
|------|------|-----------------|
| [`fe-anti-pattern-guard`](skills/fe-anti-pattern-guard/) | React/프론트엔드 컴포넌트 작성·수정·리뷰 시 자동 점검하는 안티패턴 가드레일. Props drilling(→ TanStack Query 캐시), 중첩 삼항, God file, `useMemo`/`useCallback`/`useEffect` 과사용, 콜로케이션, Rule of Three, 레거시/중복 코드 표시 등 9개 규칙. | 직접 제작 (개인). 이 저장소 `skills/fe-anti-pattern-guard/` |
| [`react-doctor`](skills/react-doctor/) | React 코드베이스의 보안·성능·정확성·아키텍처 이슈를 스캔해 0~100점 진단 리포트를 출력. React 변경 직후 실행해 조기 점검. | npm 패키지 `react-doctor` 래퍼 — `npx -y react-doctor@latest . --verbose --diff`. 이 저장소 `skills/react-doctor/` |

### 소스 유실 — 제거됨 (참고)

개인 FE 에이전트 팩(`~/fe-agent-pack`)이 삭제되어 아래 두 스킬은 심링크가 깨진 상태였고, 파일 복구가 불가능하여 `~/.claude/skills/`에서 **제거했습니다**(2026-07-06).

| 스킬 | 상태 | 원래 위치 |
|------|------|-----------|
| `fe-review-checklist` | 🗑️ 제거됨 (원본 파일 유실) | `~/fe-agent-pack/skills/fe-review-checklist` |
| `fe-scaffold` | 🗑️ 제거됨 (원본 파일 유실) | `~/fe-agent-pack/skills/fe-scaffold` |

> 다시 쓰려면 `~/fe-agent-pack` 백업 또는 원본 저장소를 복구한 뒤 심링크를 재생성하세요.

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

## 스킬 설치 위치 참고

| 경로 | 용도 |
|------|------|
| `~/.claude/skills/` | Claude Code 글로벌 스킬 (심링크 포함) |
| `~/.agents/skills/` | 크로스 에이전트 스킬 설치 소스 (`vercel-labs/skills` CLI 관리) |
| `~/.agents/.skill-lock.json` | 서드파티 스킬 설치 출처 잠금 파일 |
| `~/.claude/plugins/` | 마켓플레이스 플러그인 (번들 스킬 포함) |

*문서 작성 기준일: 2026-07-06*
