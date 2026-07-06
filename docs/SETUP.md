# 환경 세팅 카탈로그

`./bootstrap.sh` 한 번으로 새 머신에 세팅되는 **전체 항목**과 각 구성요소를 정리한 문서입니다.
회사 관련 정보·비밀은 포함하지 않으며, 토큰·개인 헬퍼는 커밋되지 않는 `~/.secrets.zsh`로 분리됩니다.

> 문서 기준일: 2026-07-06 · 원본 저장소: `kangyongseok/skills`

---

## `bootstrap.sh` 실행 시 벌어지는 일 (요약)

| 단계 | 대상 | 동작 | 안전장치 |
|------|------|------|----------|
| 1 | dotfiles(zsh) | `~/.zshrc`·`~/.zprofile`·`~/.p10k.zsh`를 이 저장소로 심링크, `~/.secrets.zsh` 템플릿 생성 | 기존 실제 파일은 `~/.dotfiles-backup-<타임스탬프>/`로 백업 |
| 2 | git | `include.path`로 `git/aliases.gitconfig` 연결 (alias + color) | 개인 식별정보(user.name/email)는 미포함 → 머신별 직접 설정 |
| 3 | 에디터 확장 | `editors/{vscode,cursor}-extensions.txt`를 `code`/`cursor` CLI로 설치 | CLI 미탐지 시 건너뜀 · `SKIP_EDITOR_EXT=1`로 생략 가능 |
| 4 | Claude Code | `install.sh` — 스킬·에이전트·커맨드를 `~/.claude`에 심링크 | 멱등 · 무관 링크 무손상 |

실행 후: `~/.secrets.zsh`에 토큰 입력 → `exec zsh`로 리로드.

---

## 1. 터미널 (dotfiles)

| 파일 | 링크 위치 | 내용 |
|------|-----------|------|
| `dotfiles/zshrc` | `~/.zshrc` | oh-my-zsh + Powerlevel10k 테마, PATH(ruby·openjdk17·nvm·pnpm·bun·android sdk·antigravity), `vim→nvim` alias, `~/.secrets.zsh` 자동 source |
| `dotfiles/zprofile` | `~/.zprofile` | Homebrew shellenv (주석 상태) |
| `dotfiles/p10k.zsh` | `~/.p10k.zsh` | Powerlevel10k 프롬프트 설정 (1831줄, 생성 파일) |
| `dotfiles/secrets.zsh.example` | → `~/.secrets.zsh` 복사 | 토큰/개인 헬퍼 템플릿 (실파일은 git-ignore) |

**필수 선행조건** (dotfiles가 참조하는 외부 도구):
- [oh-my-zsh](https://ohmyz.sh/), [Powerlevel10k](https://github.com/romkatv/powerlevel10k), `zsh-autosuggestions`
- `nvm`, `pnpm`, `bun`, `nvim`, (선택) Android SDK / openjdk@17 / ruby

**채워야 하는 시크릿** (`~/.secrets.zsh`, 커밋 금지):
- 봇/서비스 토큰(예: `SLACK_BOT_TOKEN`)
- 워크플로우별 개인 셸 함수/비공개 도메인

---

## 2. git alias + color (`git/aliases.gitconfig`)

`git config --global include.path`로 연결됩니다. 개인 `user.name/email`은 포함하지 않습니다.

| alias | 확장 명령 | alias | 확장 명령 |
|-------|-----------|-------|-----------|
| `st` | `status` | `co` | `checkout` |
| `br` | `branch` | `ci` | `commit` |
| `ps` | `push` | `pl` | `pull` |
| `cp` | `cherry-pick` | `sh` | `stash` |
| `unstage` | `reset HEAD --` | `last` | `log -1 HEAD` |
| `history` | `log --pretty=oneline` | `alias` | 등록된 alias 나열 |
| `b` | 현재 브랜치명 출력 | `lg` | 그래프 로그(색상·상대시간·전체 브랜치) |
| `feat` / `feat-s` | `flow feature start` | `feat-f` | `flow feature finish` |
| `hotfix` | `flow hotfix start` | `bugfix` | `flow bugfix start` |
| `release` / `rel` | `flow release start` | — | — |
| `wt` | `worktree` | `wtl` | `worktree list` |
| `wta` | `worktree add` | `wtr` | `worktree remove` |
| `wtm` | `worktree move` | `wtp` | `worktree prune` |

`color.ui = true` 적용. (`feat`/`hotfix` 계열은 [git-flow](https://github.com/nvie/gitflow) 설치 필요)

---

## 3. 에디터 확장

`code`/`cursor` CLI가 PATH 또는 표준 앱 경로에 있으면 `--install-extension`으로 일괄 설치합니다.

### 3-1. VSCode + Cursor 공통 (21개)

| 확장 ID | 용도 |
|---------|------|
| `bradlc.vscode-tailwindcss` | Tailwind CSS IntelliSense |
| `dbaeumer.vscode-eslint` | ESLint 통합 |
| `esbenp.prettier-vscode` | Prettier 포매터 |
| `styled-components.vscode-styled-components` | styled-components 문법 하이라이트 |
| `ccjr.emotion-auto-css` / `ijs.emotionsnippets` | Emotion CSS 지원·스니펫 |
| `csstools.postcss` / `vunguyentuan.vscode-postcss` | PostCSS 언어 지원 |
| `burkeholland.simple-react-snippets` | React 스니펫 |
| `rodsarhan.tstypecolorpreview` | TS 타입 색상 프리뷰 |
| `figma.figma-vscode-extension` | Figma 연동 |
| `eamodio.gitlens` | Git blame·히스토리 강화 |
| `mhutchie.git-graph` | Git 그래프 뷰 |
| `donjayamanne.githistory` / `huizhou.githd` | Git 히스토리·diff |
| `pkief.material-icon-theme` | 파일 아이콘 테마 |
| `daltonmenezes.aura-theme` | Aura 컬러 테마 |
| `oderwat.indent-rainbow` / `tal7aouy.rainbow-bracket` | 인덴트·괄호 색상 |
| `antiantisepticeye.vscode-color-picker` | 컬러 피커 |
| `ms-ceintl.vscode-language-pack-ko` | 한국어 언어팩 |

### 3-2. Cursor 전용 추가 (18개)

| 확장 ID | 용도 |
|---------|------|
| `anthropic.claude-code` | Claude Code IDE 연동 |
| `openai.chatgpt` | ChatGPT |
| `google.gemini-cli-vscode-ide-companion` | Gemini CLI 컴패니언 |
| `ms-python.python` / `ms-python.debugpy` | Python 언어·디버거 |
| `anysphere.cursorpyright` | Python 타입체크(Pyright, Cursor) |
| `ms-azuretools.vscode-docker` | Docker |
| `ms-vscode-remote.remote-containers` | Dev Containers |
| `anysphere.remote-ssh` | 원격 SSH (Cursor) |
| `github.vscode-github-actions` | GitHub Actions |
| `prisma.prisma-insider` | Prisma ORM (Insider) |
| `redhat.vscode-yaml` | YAML |
| `silvenon.mdx` / `xyc.vscode-mdx-preview` | MDX 문법·프리뷰 |
| `mechatroner.rainbow-csv` | CSV 색상 |
| `expo.vscode-expo-tools` | Expo(React Native) 도구 |
| `gulajavaministudio.mayukaithemevsc` | Mayukai 컬러 테마 |
| `highagency.pencildev` | 개발 보조 도구 (용도 확인 필요) |

> 목록은 `~/.vscode/extensions`·`~/.cursor/extensions` 실제 설치 폴더 기준으로 추출(버전 접미사·`extensions.json` 제외). 재추출: `ls ~/.cursor/extensions | sed -E 's/-[0-9]+\..*$//' | sort -u`.

---

## 4. Claude Code 자산 (`install.sh`)

`~/.claude/{skills,agents,commands}`에 심링크되는 개인 자산입니다. 상세는 [README](../README.md) 참고.

| 자산 | 유형 |
|------|------|
| `fe-onboarder` | agent — 낯선 레포 매핑 → ORIENTATION.md |
| `fe-review-checklist` | skill — 개인 PR 리뷰 워크플로우 |
| `fe-scaffold` | skill — 개인 컨벤션 스캐폴더 |
| `/fe-audit` | command — a11y+성능 감사 |
| `fe-anti-pattern-guard`, `react-doctor` | skill — 이 저장소에 포함된 내 스킬 |

---

## 재현·롤백

- **재실행 안전**: `bootstrap.sh`·`install.sh` 모두 멱등. 이미 링크된 항목은 no-op.
- **롤백**: `./uninstall.sh`(Claude 링크만 제거). dotfiles는 `~/.dotfiles-backup-<타임스탬프>/`에서 복구.
- **에디터 확장 생략**: `SKIP_EDITOR_EXT=1 ./bootstrap.sh`.
