#!/system/bin/sh

# OpenP2P Magisk Module 管理脚本
# 作者: 232252
# 版本: 1.0

MODULE_DIR="/data/adb/modules/openp2p"
OPENP2P_BIN="$MODULE_DIR/openp2p"
CONFIG_FILE="$MODULE_DIR/config/config.json"
LOG_DIR="$MODULE_DIR/log"
LOG_FILE="$LOG_DIR/openp2p.log"
PID_FILE="$MODULE_DIR/openp2p.pid"

# 从配置文件读取 Token（支持字符串和数字格式）
get_token() {
    if [ -f "$CONFIG_FILE" ]; then
        # 尝试匹配字符串格式
        TOKEN=$(grep -o '"Token": *"[^"]*"' "$CONFIG_FILE" | sed 's/"Token": *"\([^"]*\)"/\1/')
        if [ -z "$TOKEN" ] || [ "$TOKEN" = "YOUR_TOKEN_HERE" ]; then
            # 尝试匹配数字格式
            TOKEN=$(grep -o '"Token": *[0-9]*' "$CONFIG_FILE" | grep -o '[0-9]*')
        fi
        echo "$TOKEN"
    fi
}

# 更新模块描述
update_status() {
    local status=$1
    local token=$2
    local prop_file="$MODULE_DIR/module.prop"
    
    if [ -f "$prop_file" ]; then
        sed -i "s/^description=.*/description=OpenP2P内网穿透服务 | $status | Token: $token/" "$prop_file"
    fi
}

# 启动服务
start() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "OpenP2P 已在运行 (PID: $PID)"
            exit 0
        fi
    fi
    
    TOKEN=$(get_token)
    if [ -z "$TOKEN" ] || [ "$TOKEN" = "YOUR_TOKEN_HERE" ]; then
        echo "错误: 请先在 config/config.json 中配置 Token"
        exit 1
    fi
    
    echo "正在启动 OpenP2P..."
    
    DEVICE_NAME="$(getprop ro.product.brand)-$(getprop ro.product.model)"
    
    mkdir -p "$LOG_DIR"
    
    cd "$MODULE_DIR"
    nohup "$OPENP2P_BIN" -token "$TOKEN" -node "$DEVICE_NAME"  > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    
    sleep 2
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "OpenP2P 已启动 (PID: $PID)"
            update_status "运行中" "$TOKEN"
        else
            echo "启动失败，请查看日志: $LOG_FILE"
            tail -10 "$LOG_FILE"
            exit 1
        fi
    else
        echo "启动失败"
        exit 1
    fi
}

# 停止服务
stop() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "正在停止 OpenP2P..."
            kill $PID
            rm -f "$PID_FILE"
            sleep 1
            echo "OpenP2P 已停止"
            update_status "已停止" "-"
        else
            echo "OpenP2P 未运行"
            rm -f "$PID_FILE"
        fi
    else
        echo "OpenP2P 未运行"
    fi
}

# 重启服务
restart() {
    stop
    sleep 2
    start
}

# 查看状态
status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "OpenP2P 运行中"
            echo ""
            ps -ef | grep openp2p | grep -v grep
            echo ""
            echo "网络连接:"
            netstat -an 2>/dev/null | grep -E "27183|26188" | head -5
        else
            echo "OpenP2P 未运行 (PID文件存在但进程已退出)"
        fi
    else
        echo "OpenP2P 未运行"
    fi
}

# 查看日志
logs() {
    if [ -f "$LOG_FILE" ]; then
        tail -50 "$LOG_FILE"
    else
        echo "日志文件不存在: $LOG_FILE"
    fi
}

# 主入口
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    log)
        logs
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|log}"
        exit 1
        ;;
esac
