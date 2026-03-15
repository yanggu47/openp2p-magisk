#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="${MODDIR}/config/config.json"
LOG_FILE="${MODDIR}/log.log"
MODULE_PROP="${MODDIR}/module.prop"
OPENP2P="${MODDIR}/openp2p"

# 从配置文件读取 Token
get_token() {
    if [ -f "$CONFIG_FILE" ]; then
        grep -o '"Token": [0-9]*' "$CONFIG_FILE" | grep -o '[0-9]*'
    fi
}

# 更新 module.prop 文件中的 description
update_module_description() {
    local status_message=$1
    sed -i "/^description=/c\description=[状态]${status_message}" ${MODULE_PROP}
}

# 检查 TUN 设备
if [ ! -e /dev/net/tun ]; then
    if [ ! -d /dev/net ]; then
        mkdir -p /dev/net
    fi
    ln -s /dev/tun /dev/net/tun 2>/dev/null
fi

# 主循环
while true; do
    # 检查是否禁用
    if ls ${MODDIR} | grep -q "disable"; then
        update_module_description "已禁用"
        if pgrep -f 'openp2p -d' >/dev/null; then
            echo "$(date "+%Y-%m-%d %H:%M:%S") 模块已禁用，正在关闭..."
            pkill openp2p 2>/dev/null
        fi
    else
        # 检查进程是否存在
        if ! pgrep -f 'openp2p -d' >/dev/null; then
            if [ ! -f "$CONFIG_FILE" ]; then
                update_module_description "config.json 不存在"
                sleep 3s
                continue
            fi
            
            TOKEN=$(get_token)
            if [ -z "$TOKEN" ] || [ "$TOKEN" = "YOUR_TOKEN_HERE" ]; then
                update_module_description "请先配置 Token"
                echo "$(date "+%Y-%m-%d %H:%M:%S") 请先在 config/config.json 中配置 Token"
                sleep 10s
                continue
            fi

            echo "$(date "+%Y-%m-%d %H:%M:%S") 正在启动 OpenP2P..."
            
            # 获取设备名称
            DEVICE_NAME="$(getprop ro.product.brand)-$(getprop ro.product.model)"
            
            # 从配置文件读取参数启动
            cd ${MODDIR}
            TZ=Asia/Shanghai ${OPENP2P} -d \
                -token ${TOKEN} \
                -node "${DEVICE_NAME}" \
                -serverhost api.openp2p.cn \
                -loglevel 1 \
                -sharebandwidth 50 \
                -insecure > ${LOG_FILE} 2>&1 &
            
            sleep 5s
            
            # 检查是否启动成功
            if pgrep -f 'openp2p -d' >/dev/null; then
                update_module_description "主程序已开启 | 节点: ${DEVICE_NAME}"
                echo "$(date "+%Y-%m-%d %H:%M:%S") OpenP2P 启动成功"
            else
                update_module_description "主程序启动失败，请检查日志"
                echo "$(date "+%Y-%m-%d %H:%M:%S") OpenP2P 启动失败"
            fi
        else
            echo "$(date "+%Y-%m-%d %H:%M:%S") OpenP2P 运行中..."
        fi
    fi
    
    sleep 10s
done
