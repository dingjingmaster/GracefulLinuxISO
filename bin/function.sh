#!/bin/bash

# 输出信息
_msg_info()
{
    local _msg="${1}"
    printf '\033[32m[%s] [Info] %s\033[0m\n' "${appName}" "${_msg}" | sed ':label;N;s/\n/ /g;b label' | sed 's/[ ][ ]*/ /g'
}

# 输出信息
_msg_info_pure()
{
    local _msg="${1}"
    printf '%s\n' "${_msg}"
}

# 输出警告
_msg_warning()
{
    local _msg="${1}"
    printf '\033[33m[%s] [Warn] %s\033[0m\n' "${appName}" "${_msg}" >&2
}

# 输出错误
_msg_error()
{
    local _msg="${1}"
    local _error="${2}"
    printf '\033[31m[%s] [Error] %s\033[0m\n' "${appName}" "${_msg}" >&2

    if (( _error > 0 )); then
        exit "${_error}"
    fi
}

# 使用 pacman 将包安装到根文件系统
_pacman()
{
    _msg_info "install '${rootfsDir}/' ..."
    _msg_info "pacstrap -C ${confDir}/pacman.conf -c -G -M -- ${rootfsDir} $@"
    pacstrap -C "${confDir}/pacman.conf" -c -G -M -- "${rootfsDir}" "$@"
}

# 制作镜像前打印相关信息
_show_config()
{
    _msg_info_pure "${appName} Configure："
    _msg_info_pure "                  Arch:       ${arch}"
    _msg_info_pure "               GPG key:       ${gpgKey:-None}"
    _msg_info_pure "       GPG public file:       ${gpgPubKeyFile}"
    _msg_info_pure "        Work directory:       ${workDir}"
    _msg_info_pure "   Configure directory:       ${confDir}"
    _msg_info_pure "    Pacman config file:       ${pacmanConf}"
    _msg_info_pure "        Root directory:       ${rootfsDir}"
    _msg_info_pure "      Install packages:       ${pkgList[*]}"
}

# 导出 GPG
_export_gpg_pubkey()
{
    [[ -n "${gpgKey}" ]] && [[ ! -f ${gpgPubKeyFile} ]] && gpg --batch --output "${gpgPubKeyFile}" --export "${gpgKey}"
    [[ -f "${gpgPubKeyFile}" ]] && exec {ISO_GNUPG_FD}<>"${gpgPubKeyFile}" && export ISO_GNUPG_FD
}

# 生成文件系统
_make_packages()
{
    _msg_info "Starting install packages..."
    sudo pacstrap -C "${pacmanConf}" -c -G -M -- "${rootfsDir}" "${pkgList[@]}" >1 2>&1
}

# 输出镜像中安装的包列表
_show_installed_packages()
{
    local isoPkgLists
    mapfile -t isoPkgLists < <(sudo pacman -Q --sysroot "${rootfsDir}" | sed 's/ /=/')
    _msg_info "${isoPkgLists[*]}"
}



