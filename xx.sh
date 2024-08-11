#!/bin/bash

# 定义路径
REPO_PATH="."         # 当前 repo 目录
DEBS_PATH="./debs"    # debs 目录位于 repo 目录中

# 生成 Packages.gz 和 Packages.bz2 文件的函数
generate_packages() {
  local dir="$1"
  cd "$dir" || exit
  dpkg-scanpackages . /dev/null > Packages
  gzip -9c Packages > Packages.gz
  bzip2 -9c Packages > Packages.bz2
}

# 备份旧的 Packages 文件
backup_files() {
  local repo="$1"
  cd "$repo" || exit
  [ -f Packages.gz ] && mv Packages.gz Packages.gz.bak
  [ -f Packages.bz2 ] && mv Packages.bz2 Packages.bz2.bak
}

# 替换 repo 目录中的 Packages 文件
replace_files() {
  local repo="$1"
  local src_dir="$2"
  cp "$src_dir/Packages.gz" "$repo/"
  cp "$src_dir/Packages.bz2" "$repo/"
}

# 执行任务
main() {
  # 生成临时目录
  local temp_dir=$(mktemp -d)

  # 备份旧文件
  backup_files "$REPO_PATH"

  # 扫描 rootfull 文件夹并生成 Packages 文件
  generate_packages "$DEBS_PATH/rootfull"
  cp "$DEBS_PATH/rootfull/Packages.gz" "$temp_dir/"
  cp "$DEBS_PATH/rootfull/Packages.bz2" "$temp_dir/"

  # 扫描 rootless 文件夹并生成 Packages 文件
  generate_packages "$DEBS_PATH/rootless"
  cp "$DEBS_PATH/rootless/Packages.gz" "$temp_dir/"
  cp "$DEBS_PATH/rootless/Packages.bz2" "$temp_dir/"

  # 替换 repo 目录中的 Packages 文件
  replace_files "$REPO_PATH" "$temp_dir"

  # 清理临时目录
  rm -rf "$temp_dir"

  echo "Packages files updated successfully."
}

main
