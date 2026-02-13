#!/usr/bin/env bash
set -euo pipefail

# 检测并使用 venv 的 Python
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PYTHON="${SCRIPT_DIR}/.venv/bin/python"

if [[ ! -x "$VENV_PYTHON" ]]; then
  echo "Error: venv Python not found at $VENV_PYTHON" >&2
  echo "Please run: python3 -m venv .venv && .venv/bin/pip install -r requirements.txt" >&2
  exit 1
fi

export CONFIG__GIT_PROVIDER=bitbucket
export CONFIG__REASONING_EFFORT=high
export BITBUCKET__AUTH_TYPE=basic
BITBUCKET__BASIC_TOKEN=$(echo -n "$ATLASSIAN_BITBUCKET_USER_EMAIL:$ATLASSIAN_BITBUCKET_API_TOKEN" | base64)
export BITBUCKET__BASIC_TOKEN
export OPENAI__KEY=$OPENAI_API_KEY

BITBUCKET_WORKSPACE=$ATLASSIAN_BITBUCKET_JASON_WORKSPACE
BITBUCKET_REPO_SLUG=lets-civet.windows.repair
BITBUCKET_PR_ID=50

PULL_REQUEST_URL="https://bitbucket.org/${BITBUCKET_WORKSPACE}/${BITBUCKET_REPO_SLUG}/pull-requests/${BITBUCKET_PR_ID}"

PYTHONPATH=. "$VENV_PYTHON" -m pr_agent.cli \
  --pr_url="$PULL_REQUEST_URL" \
  describe

PYTHONPATH=. "$VENV_PYTHON" -m pr_agent.cli \
  --pr_url="$PULL_REQUEST_URL" \
  review

PYTHONPATH=. "$VENV_PYTHON" -m pr_agent.cli \
  --pr_url="$PULL_REQUEST_URL" \
  improve