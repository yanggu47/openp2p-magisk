#!/system/bin/sh
# OpenP2P 卸载脚本

MODDIR=${0%/*}

# 停止进程
pkill openp2p 2>/dev/null

# 清理
rm -rf /data/adb/openp2p 2>/dev/null

echo "OpenP2P 已卸载"
