#!/bin/bash

set -e -u

isoVersion="0.0.0"

curDir=$(dirname $(realpath -- $0))
appName="GracefulLinux"
gpgKey="dingjing@live.cn"

binDir="${curDir}/bin"
workDir="${curDir}/work"
confDir="${curDir}/config"
rootfsDir="${workDir}/rootfs"

pacmanConf="${confDir}/pacman.conf"

arch=$(uname -m)
gpgPubKeyFile="${workDir}/pubkey.gpg"
packages="${confDir}/packages.$(uname -m)"


pkgList=()

source ${binDir}/function.sh

# 检查安装包列表的配置文件是否存在
[[ ! -f ${packages} ]]  && _msg_error "Configure file '${packages}' is not exists!" -1

# 权限检查
if (( EUID == 0 )); then _msg_error "${appName} not run as root!" 1 ; fi

# 创建临时文件夹
[[ ! -d ${workDir} ]]   && $(mkdir -p ${workDir}   || _msg_error "mkdir '${workDir}'   error!" -1)
[[ ! -d ${rootfsDir} ]] && $(mkdir -p ${rootfsDir} || _msg_error "mkdir '${rootfsDir}' error!" -1)

# 获取要安装的软件包
mapfile -t pkgList < <(sed '/^[[:blank:]]*#.*/d;s/#.*//;/^[[:blank:]]*$/d' "${packages}")

# 显示配置
_show_config

# 导出 GPG key
_export_gpg_pubkey

# 生成文件系统
_make_packages

# 输出镜像中安装的包列表
_show_installed_packages
