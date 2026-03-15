#!/data/adb/magisk/busybox sh
MODDIR=${0%/*}
chmod 755 ${MODDIR}/*

# 等待系统启动成功
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 5s
done

# 防止系统挂起
echo "PowerManagerService.noSuspend" > /sys/power/wake_lock

# 修改模块描述
sed -i 's/^description=.*/description=[状态]启动中.../' "$MODDIR/module.prop"

# 等待网络就绪
sleep 10s

# 启动核心服务
"${MODDIR}/openp2p_core.sh" &
