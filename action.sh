#!/system/bin/sh
# OpenP2P 管理脚本

MODDIR=${0%/*}
OPENP2P="${MODDIR}/openp2p"
CONFIG_FILE="${MODDIR}/config/config.json"
LOG_FILE="${MODDIR}/log.log"
MODULE_PROP="${MODDIR}/module.prop"
PID_FILE="${MODDIR}/openp2p.pid"

# 从配置文件读取 Token
get_token() {
    if [ -f "$CONFIG_FILE" ]; then
        grep -o '"Token": [0-9]*' "$CONFIG_FILE" | grep -o '[0-9]*'
    fi
}

# 更新模块描述
update_status() {
    local status=$1
    sed -i "/^description=/c\description=[状态]${status}" ${MODULE_PROP}
}

case "$1" in
    start)
        echo "正在启动 OpenP2P..."
        if pgrep -f 'openp2p -d' >/dev/null; then
            echo "OpenP2P 已在运行中"
            exit 0
        fi
        
        TOKEN=$(get_token)
        if [ -z "$TOKEN" ] || [ "$TOKEN" = "YOUR_TOKEN_HERE" ]; then
            echo "错误: 请先在 config/config.json 中配置 Token"
            exit 1
        fi
        
        DEVICE_NAME="$(getprop ro.product.brand)-$(getprop ro.product.model)"
        
        cd ${MODDIR}
        ${OPENP2P} -d \
            -token ${TOKEN} \
            -node "${DEVICE_NAME}" \
            -serverhost api.openp2p.cn \
            -loglevel 1 \
            -sharebandwidth 50 \
            -insecure >> ${LOG_FILE} 2>&1 &
        
        sleep 3
        pgrep -f 'openp2p' | head -1 > ${PID_FILE}
        update_status "主程序已开启"
        echo "OpenP2P 已启动 (PID: $(cat ${PID_FILE}))"
        ;;
    
    stop)
        echo "正在停止 OpenP2P..."
        pkill openp2p 2>/dev/null
        rm -f ${PID_FILE}
        update_status "已停止"
        echo "OpenP2P 已停止"
        ;;
    
    restart)
        $0 stop
        sleep 3
        $0 start
        ;;
    
    status)
        if pgrep -f 'openp2p -d' >/dev/null; then
            echo "OpenP2P 运行中"
            echo ""
            ps -A | grep openp2p | grep -v grep
            echo ""
            echo "网络连接:"
            netstat -an 2>/dev/null | grep -E "27183.*ESTAB" | head -3
        else
            echo "OpenP2P 未运行"
        fi
        ;;
    
    log)
        echo "最近日志:"
        tail -30 ${LOG_FILE}
        ;;
    
    *)
        echo "用法: $0 {start|stop|restart|status|log}"
        exit 1
        ;;
esac
