#!/bin/bash

# 🚀 自动壁纸更换系统安装脚本
# 作者：为zyh定制
# 功能：安装、启动、停止、卸载壁纸更换服务

# 🎨 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 📁 路径定义
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
WALLPAPER_SCRIPT="$SCRIPT_DIR/wallpaper_changer.sh"
SERVICE_FILE="$SCRIPT_DIR/wallpaper-changer.service"
TIMER_FILE="$SCRIPT_DIR/wallpaper-changer.timer"

# 🎯 函数：打印彩色消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 🎯 函数：检查文件是否存在
check_files() {
    local missing_files=()

    if [ ! -f "$WALLPAPER_SCRIPT" ]; then
        missing_files+=("wallpaper_changer.sh")
    fi

    if [ ! -f "$SERVICE_FILE" ]; then
        missing_files+=("wallpaper-changer.service")
    fi

    if [ ! -f "$TIMER_FILE" ]; then
        missing_files+=("wallpaper-changer.timer")
    fi

    if [ ${#missing_files[@]} -gt 0 ]; then
        print_message $RED "❌ 缺少以下文件："
        for file in "${missing_files[@]}"; do
            print_message $RED "   - $file"
        done
        exit 1
    fi
}

# 🎯 函数：安装服务
install_service() {
    print_message $BLUE "🚀 开始安装自动壁纸更换服务..."

    # 检查必要文件
    check_files

    # 创建systemd用户目录
    mkdir -p "$SYSTEMD_USER_DIR"

    # 给脚本添加执行权限
    chmod +x "$WALLPAPER_SCRIPT"
    print_message $GREEN "✅ 已设置脚本执行权限"

    # 复制服务文件
    cp "$SERVICE_FILE" "$SYSTEMD_USER_DIR/"
    cp "$TIMER_FILE" "$SYSTEMD_USER_DIR/"
    print_message $GREEN "✅ 已复制服务文件到 $SYSTEMD_USER_DIR"

    # 重新加载systemd配置
    systemctl --user daemon-reload
    print_message $GREEN "✅ 已重新加载systemd配置"

    # 启用并启动定时器
    systemctl --user enable wallpaper-changer.timer
    systemctl --user start wallpaper-changer.timer
    print_message $GREEN "✅ 已启用并启动定时器"

    # 测试脚本
    print_message $YELLOW "🧪 测试壁纸更换..."
    "$WALLPAPER_SCRIPT" --test

    print_message $GREEN "🎉 安装完成！壁纸将每5分钟自动更换一次。"
    print_message $CYAN "📝 查看日志：tail -f ~/.wallpaper_changer.log"
}

# 🎯 函数：卸载服务
uninstall_service() {
    print_message $YELLOW "🗑️ 开始卸载自动壁纸更换服务..."

    # 停止并禁用定时器
    systemctl --user stop wallpaper-changer.timer 2>/dev/null
    systemctl --user disable wallpaper-changer.timer 2>/dev/null
    print_message $GREEN "✅ 已停止并禁用定时器"

    # 删除服务文件
    rm -f "$SYSTEMD_USER_DIR/wallpaper-changer.service"
    rm -f "$SYSTEMD_USER_DIR/wallpaper-changer.timer"
    print_message $GREEN "✅ 已删除服务文件"

    # 重新加载systemd配置
    systemctl --user daemon-reload
    print_message $GREEN "✅ 已重新加载systemd配置"

    print_message $GREEN "🎉 卸载完成！"
}

# 🎯 函数：显示服务状态
show_status() {
    print_message $BLUE "📊 自动壁纸更换服务状态："
    echo ""

    print_message $CYAN "⏰ 定时器状态："
    systemctl --user status wallpaper-changer.timer --no-pager
    echo ""

    print_message $CYAN "🔧 服务状态："
    systemctl --user status wallpaper-changer.service --no-pager
    echo ""

    print_message $CYAN "📝 最近的日志："
    if [ -f "$HOME/.wallpaper_changer.log" ]; then
        tail -5 "$HOME/.wallpaper_changer.log"
    else
        print_message $YELLOW "日志文件不存在"
    fi
}

# 🎯 函数：启动服务
start_service() {
    print_message $BLUE "▶️ 启动自动壁纸更换服务..."
    systemctl --user start wallpaper-changer.timer
    print_message $GREEN "✅ 服务已启动"
}

# 🎯 函数：停止服务
stop_service() {
    print_message $BLUE "⏸️ 停止自动壁纸更换服务..."
    systemctl --user stop wallpaper-changer.timer
    print_message $GREEN "✅ 服务已停止"
}

# 🎯 函数：暂停服务
pause_service() {
    print_message $BLUE "⏸️ 暂停自动壁纸更换服务..."
    "$WALLPAPER_SCRIPT" --pause
    print_message $GREEN "✅ 服务已暂停"
}

# 🎯 函数：恢复服务
resume_service() {
    print_message $BLUE "▶️ 恢复自动壁纸更换服务..."
    "$WALLPAPER_SCRIPT" --resume
    print_message $GREEN "✅ 服务已恢复"
}

# 🎯 函数：清理日志
clean_logs() {
    print_message $BLUE "🧹 清理日志文件..."
    "$WALLPAPER_SCRIPT" --clean-logs
}

# 🎯 函数：设置轮换模式
set_mode() {
    local mode="$1"
    if [ -z "$mode" ]; then
        print_message $RED "❌ 请指定轮换模式 (random 或 sequential)"
        exit 1
    fi

    print_message $BLUE "🔄 设置轮换模式为: $mode"
    "$WALLPAPER_SCRIPT" --mode "$mode"
}

# 🎯 函数：显示详细状态
show_detailed_status() {
    print_message $BLUE "📊 详细状态信息："
    echo ""
    "$WALLPAPER_SCRIPT" --status
}

# 🎯 函数：显示帮助信息
show_help() {
    print_message $PURPLE "🎨 自动壁纸更换系统管理脚本 v2.0"
    echo ""
    print_message $CYAN "用法: $0 [选项] [参数]"
    echo ""
    print_message $YELLOW "基本操作："
    echo "  install         安装并启动服务"
    echo "  uninstall       卸载服务"
    echo "  start           启动服务"
    echo "  stop            停止服务"
    echo "  status          显示服务状态"
    echo "  test            测试壁纸更换"
    echo ""
    print_message $YELLOW "高级功能："
    echo "  pause           暂停壁纸更换"
    echo "  resume          恢复壁纸更换"
    echo "  clean-logs      清理日志文件"
    echo "  mode MODE       设置轮换模式 (random/sequential)"
    echo "  info            显示详细状态"
    echo "  help            显示此帮助信息"
    echo ""
    print_message $GREEN "示例："
    echo "  $0 install              # 安装服务"
    echo "  $0 status               # 查看状态"
    echo "  $0 pause                # 暂停服务"
    echo "  $0 mode sequential      # 设置为顺序模式"
    echo "  $0 clean-logs           # 清理日志"
}

# 🎯 主函数
main() {
    case "$1" in
        "install")
            install_service
            ;;
        "uninstall")
            uninstall_service
            ;;
        "start")
            start_service
            ;;
        "stop")
            stop_service
            ;;
        "status")
            show_status
            ;;
        "test")
            check_files
            "$WALLPAPER_SCRIPT" --test
            ;;
        "pause")
            check_files
            pause_service
            ;;
        "resume")
            check_files
            resume_service
            ;;
        "clean-logs")
            check_files
            clean_logs
            ;;
        "mode")
            check_files
            set_mode "$2"
            ;;
        "info")
            check_files
            show_detailed_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            print_message $RED "❌ 请指定操作选项"
            echo ""
            show_help
            exit 1
            ;;
        *)
            print_message $RED "❌ 未知选项: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 🚀 启动脚本
main "$@"
