# OpenP2P Magisk Module

[![Update Binary](https://github.com/232252/openp2p-magisk/actions/workflows/update.yml/badge.svg)](https://github.com/232252/openp2p-magisk/actions/workflows/update.yml)
[![GitHub release](https://img.shields.io/github/release/232252/openp2p-magisk.svg)](https://github.com/232252/openp2p-magisk/releases)

Android Magisk 模块，实现 OpenP2P 内网穿透服务的开机自启动和后台运行。

## 📖 项目来源

本项目基于 [OpenP2P](https://github.com/openp2p-cn/openp2p) 官方项目打包为 Magisk 模块。

- **上游项目**: https://github.com/openp2p-cn/openp2p
- **上游版本**: v3.25.7
- **模块版本**: 32507

## ✨ 功能特性

- ✅ 开机自启动
- ✅ 进程守护（自动重启）
- ✅ 支持 start/stop/restart/status/log 管理命令
- ✅ 从配置文件读取 Token
- ✅ 自动获取设备名称
- ✅ 支持 GitHub Actions 自动更新二进制文件

## 📦 安装方法

### 方法一：下载 Release 包

1. 前往 [Releases](https://github.com/232252/openp2p-magisk/releases) 页面
2. 下载最新的 `openp2p-magisk-vX.X.X.zip`
3. 在 Magisk Manager 中选择"从本地安装"
4. 选择下载的 zip 文件
5. 重启手机

### 方法二：手动安装

```bash
# 克隆仓库
git clone https://github.com/232252/openp2p-magisk.git

# 进入目录
cd openp2p-magisk

# 压缩为 zip
zip -r openp2p-magisk.zip *

# 通过 adb 推送到手机
adb push openp2p-magisk.zip /sdcard/

# 在 Magisk Manager 中安装
```

## ⚙️ 配置

安装后，编辑 `/data/adb/modules/openp2p/config/config.json`：

```json
{
  "network": {
    "Token": "YOUR_TOKEN_HERE",
    "ShareBandwidth": 50,
    "ServerHost": "api.openp2p.cn"
  }
}
```

**重要**: 将 `YOUR_TOKEN_HERE` 替换为你的实际 Token（从 https://console.openp2p.cn 获取）

## 🔧 管理命令

```bash
# 启动
/data/adb/modules/openp2p/action.sh start

# 停止
/data/adb/modules/openp2p/action.sh stop

# 重启
/data/adb/modules/openp2p/action.sh restart

# 查看状态
/data/adb/modules/openp2p/action.sh status

# 查看日志
/data/adb/modules/openp2p/action.sh log
```

## 📁 模块结构

```
/data/adb/modules/openp2p/
├── openp2p           # 主程序
├── module.prop       # 模块信息
├── service.sh        # Magisk 开机启动入口
├── openp2p_core.sh   # 核心守护脚本
├── action.sh         # 管理脚本
├── uninstall.sh      # 卸载脚本
└── config/
    └── config.json   # 配置文件
```

## 🔄 自动更新

本项目通过 GitHub Actions 自动检测 OpenP2P 官方更新：

- 每天自动检查上游新版本
- 发现新版本时自动更新二进制文件
- 自动创建 Release

## 📋 系统要求

- Android 设备已 Root
- Magisk v20.4+
- ARM64 架构

## 🔗 相关链接

- OpenP2P 官网: https://openp2p.cn
- OpenP2P 控制台: https://console.openp2p.cn
- OpenP2P GitHub: https://github.com/openp2p-cn/openp2p
- Magisk 官网: https://topjohnwu.github.io/Magisk/

## 📜 许可证

本项目采用 MIT 许可证。

OpenP2P 二进制文件遵循其原始许可证。

## 🙏 致谢

- [OpenP2P](https://github.com/openp2p-cn/openp2p) - 核心内网穿透功能
- [Magisk](https://github.com/topjohnwu/Magisk) - Android Root 框架
