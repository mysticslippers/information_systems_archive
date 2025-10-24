#!/bin/bash

GITHUB_USER="mysticslippers"
BASE_REPO_URL="https://github.com/$GITHUB_USER"
LABS_DIR="labs"

mkdir -p "$LABS_DIR"

LABS=(
  "lab1-inf-sys-backend"
  "lab2-inf-sys-backend"
  "lab3-inf-sys-backend"
)


for LAB in "${LABS[@]}"; do
  TARGET_DIR="$LABS_DIR/$LAB"
  REPO_URL="$BASE_REPO_URL/$LAB.git"

  if [ -d "$TARGET_DIR" ]; then
    echo "Пропущено: $LAB (папка уже существует)"
  else
    echo "Добавляем $LAB ..."
    git submodule add "$REPO_URL" "$TARGET_DIR"
  fi
done

echo "Все подмодули добавлены."
echo "Теперь не забудь:"
echo "  git add .gitmodules $LABS_DIR"
echo "  git commit -m 'Добавлены подмодули лабораторных работ'"
echo "  git push"
