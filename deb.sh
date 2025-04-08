#!/bin/bash 

# 临时文件用于合并内容
temp_packages="./temp_packages"

# 确保临时目录存在
mkdir -p "$temp_packages"

# 扫描 rootfull 目录并生成 Packages 文件
dpkg-scanpackages ./debs/rootfull /dev/null > "$temp_packages/Packages_rootfull"

# 扫描 rootless 目录并生成 Packages 文件
dpkg-scanpackages ./debs/rootless /dev/null > "$temp_packages/Packages_rootless"

# 扫描 iphoneos-arm64e 目录并生成 Packages 文件
dpkg-scanpackages ./debs/iphoneos-arm64e /dev/null > "$temp_packages/Packages_iphoneos_arm64e"

sed -i 's/^Section:.*$/Section: RootHide/' "$temp_packages/Packages_iphoneos_arm64e"

# 合并所有 Packages 文件
cat "$temp_packages/Packages_rootfull" "$temp_packages/Packages_rootless" "$temp_packages/Packages_iphoneos_arm64e" > "./Packages"

# 生成合并后的 Packages 文件并压缩
gzip -9c "./Packages" > "./Packages.gz"
bzip2 -9c "./Packages" > "./Packages.bz2"

# 清理临时目录
rm -rf "$temp_packages"
