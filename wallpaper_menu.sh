#!/bin/bash

# 🎨 壁纸更换器交互式菜单 v2.0
# 作者：为zyh定制
# 功能：提供友好的交互式界面管理壁纸更换系统

# 🎨 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 📁 路径定义
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_SCRIPT="$SCRIPT_DIR/wallpaper_changer.sh"
INSTALL_SCRIPT="$SCRIPT_DIR/install_wallpaper_changer.sh"
CONFIG_DIR="$HOME/.config/wallpaper_changer"
CONFIG_FILE="$CONFIG_DIR/config"
PAUSE_FILE="$CONFIG_DIR/paused"

# 🎯 函数：打印彩色消息
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 🎯 函数：打印标题
print_header() {
    clear
    print_color $CYAN "-----------------------------------------------"
    print_color $WHITE "🎨 欢迎使用智能壁纸更换器！    版本：v2.0"

    # 获取服务状态
    local service_status="未知"
    local memory_info=""
    local mode_info="random"
    local image_count="0"

    if systemctl --user is-active wallpaper-changer.timer >/dev/null 2>&1; then
        if [ -f "$PAUSE_FILE" ]; then
            service_status="已暂停"
        else
            service_status="正在运行"
        fi
    else
        service_status="已停止"
    fi

    # 获取轮换模式
    if [ -f "$CONFIG_FILE" ]; then
        mode_info=$(grep "ROTATION_MODE=" "$CONFIG_FILE" | cut -d'=' -f2)
    fi

    # 获取图片数量
    if [ -f "$WALLPAPER_SCRIPT" ]; then
        image_count=$("$WALLPAPER_SCRIPT" --info 2>/dev/null | grep "图片数量" | grep -o '[0-9]*' | head -1)
    fi

    print_color $GREEN "壁纸服务${service_status}（${mode_info}模式），图片数量：${image_count}张"
    print_color $YELLOW "当前壁纸目录：~/Pictures"
    print_color $CYAN "GitHub：https://github.com/your-repo/wallpaper-changer"
    print_color $CYAN "-----------------------------------------------"
}

# 🎯 函数：显示主菜单
show_main_menu() {
    print_color $WHITE " 1 启动/重启服务"
    print_color $WHITE " 2 暂停/恢复服务"
    print_color $WHITE " 3 停止服务"
    print_color $WHITE " 4 轮换模式设置"
    print_color $WHITE " 5 立即更换壁纸"
    print_color $WHITE " 6 查看详细状态"
    print_color $WHITE " 7 日志管理"
    print_color $WHITE " 8 系统设置"
    print_color $WHITE " 9 安装/卸载"
    print_color $CYAN "-----------------------------------------------"
    print_color $WHITE " 0 退出脚本"
    echo -n "请输入对应数字 > "
}

# 🎯 函数：等待用户按键
wait_key() {
    echo ""
    print_color $YELLOW "按任意键继续..."
    read -n 1 -s
}

# 🎯 函数：启动/重启服务
start_service() {
    print_header
    print_color $BLUE "🚀 启动/重启壁纸更换服务..."
    echo ""

    if systemctl --user is-active wallpaper-changer.timer >/dev/null 2>&1; then
        print_color $YELLOW "服务正在运行，正在重启..."
        "$INSTALL_SCRIPT" stop
        sleep 1
    fi

    "$INSTALL_SCRIPT" start

    if [ $? -eq 0 ]; then
        print_color $GREEN "✅ 服务启动成功！"
    else
        print_color $RED "❌ 服务启动失败！"
    fi

    wait_key
}

# 🎯 函数：暂停/恢复服务
toggle_pause() {
    print_header

    if [ -f "$PAUSE_FILE" ]; then
        print_color $BLUE "▶️ 恢复壁纸更换服务..."
        "$INSTALL_SCRIPT" resume
        print_color $GREEN "✅ 服务已恢复！"
    else
        print_color $BLUE "⏸️ 暂停壁纸更换服务..."
        "$INSTALL_SCRIPT" pause
        print_color $GREEN "✅ 服务已暂停！"
    fi

    wait_key
}

# 🎯 函数：停止服务
stop_service() {
    print_header
    print_color $BLUE "⏹️ 停止壁纸更换服务..."
    echo ""

    "$INSTALL_SCRIPT" stop

    if [ $? -eq 0 ]; then
        print_color $GREEN "✅ 服务已停止！"
    else
        print_color $RED "❌ 停止服务失败！"
    fi

    wait_key
}

# 🎯 函数：轮换模式设置
rotation_mode_menu() {
    while true; do
        print_header
        print_color $WHITE "🔄 轮换模式设置"
        print_color $CYAN "-----------------------------------------------"

        # 获取当前模式
        local current_mode="random"
        if [ -f "$CONFIG_FILE" ]; then
            current_mode=$(grep "ROTATION_MODE=" "$CONFIG_FILE" | cut -d'=' -f2)
        fi

        print_color $YELLOW "当前模式：$current_mode"
        echo ""
        print_color $WHITE " 1 随机模式 (智能避重)"
        print_color $WHITE " 2 顺序模式 (依次轮换)"
        print_color $WHITE " 3 查看模式说明"
        print_color $CYAN "-----------------------------------------------"
        print_color $WHITE " 0 返回主菜单"
        echo -n "请输入对应数字 > "

        read choice
        case $choice in
            1)
                "$INSTALL_SCRIPT" mode random
                print_color $GREEN "✅ 已切换到随机模式！"
                wait_key
                ;;
            2)
                "$INSTALL_SCRIPT" mode sequential
                print_color $GREEN "✅ 已切换到顺序模式！"
                wait_key
                ;;
            3)
                print_header
                print_color $WHITE "📖 轮换模式说明"
                print_color $CYAN "-----------------------------------------------"
                print_color $YELLOW "🎲 随机模式 (random)："
                echo "   • 随机选择壁纸，但智能避免最近使用的5张"
                echo "   • 确保壁纸多样性，不会频繁重复"
                echo "   • 适合图片数量较多的情况"
                echo ""
                print_color $YELLOW "📋 顺序模式 (sequential)："
                echo "   • 按文件名顺序依次更换壁纸"
                echo "   • 确保每张图片都会被使用到"
                echo "   • 轮换完所有图片后重新开始"
                echo "   • 适合精心整理的壁纸集合"
                wait_key
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "❌ 无效选择，请重新输入！"
                sleep 1
                ;;
        esac
    done
}

# 🎯 函数：立即更换壁纸
change_wallpaper_now() {
    print_header
    print_color $BLUE "🎨 立即更换壁纸..."
    echo ""

    "$WALLPAPER_SCRIPT" --test

    if [ $? -eq 0 ]; then
        print_color $GREEN "✅ 壁纸更换成功！"
    else
        print_color $RED "❌ 壁纸更换失败！"
    fi

    wait_key
}

# 🎯 函数：查看详细状态
show_status() {
    print_header
    print_color $WHITE "📊 系统详细状态"
    print_color $CYAN "-----------------------------------------------"
    echo ""

    "$INSTALL_SCRIPT" info

    wait_key
}

# 🎯 函数：日志管理菜单
log_management_menu() {
    while true; do
        print_header
        print_color $WHITE "📝 日志管理"
        print_color $CYAN "-----------------------------------------------"

        # 获取日志文件大小
        local log_size="0"
        if [ -f "$HOME/.wallpaper_changer.log" ]; then
            log_size=$(du -h "$HOME/.wallpaper_changer.log" | cut -f1)
        fi

        print_color $YELLOW "当前日志大小：$log_size"
        echo ""
        print_color $WHITE " 1 查看最新日志"
        print_color $WHITE " 2 实时监控日志"
        print_color $WHITE " 3 清理所有日志"
        print_color $WHITE " 4 查看历史记录"
        print_color $CYAN "-----------------------------------------------"
        print_color $WHITE " 0 返回主菜单"
        echo -n "请输入对应数字 > "

        read choice
        case $choice in
            1)
                print_header
                print_color $WHITE "📄 最新日志内容 (最后20行)"
                print_color $CYAN "-----------------------------------------------"
                if [ -f "$HOME/.wallpaper_changer.log" ]; then
                    tail -20 "$HOME/.wallpaper_changer.log"
                else
                    print_color $YELLOW "日志文件不存在"
                fi
                wait_key
                ;;
            2)
                print_header
                print_color $WHITE "📺 实时日志监控 (按Ctrl+C退出)"
                print_color $CYAN "-----------------------------------------------"
                if [ -f "$HOME/.wallpaper_changer.log" ]; then
                    tail -f "$HOME/.wallpaper_changer.log"
                else
                    print_color $YELLOW "日志文件不存在"
                    wait_key
                fi
                ;;
            3)
                print_header
                print_color $YELLOW "🗑️ 确认清理所有日志文件？(y/N)"
                echo -n "> "
                read confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    "$INSTALL_SCRIPT" clean-logs
                    print_color $GREEN "✅ 日志清理完成！"
                else
                    print_color $BLUE "ℹ️ 操作已取消"
                fi
                wait_key
                ;;
            4)
                print_header
                print_color $WHITE "📚 壁纸使用历史"
                print_color $CYAN "-----------------------------------------------"
                if [ -f "$CONFIG_DIR/history" ]; then
                    echo "最近使用的壁纸："
                    tail -10 "$CONFIG_DIR/history" | while IFS='|' read -r timestamp filename filepath; do
                        echo "  $timestamp - $filename"
                    done
                else
                    print_color $YELLOW "暂无历史记录"
                fi
                wait_key
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "❌ 无效选择，请重新输入！"
                sleep 1
                ;;
        esac
    done
}

# 🎯 函数：系统设置菜单
system_settings_menu() {
    while true; do
        print_header
        print_color $WHITE "⚙️ 系统设置"
        print_color $CYAN "-----------------------------------------------"

        # 获取当前设置
        local wallpaper_dir="$HOME/Pictures"
        local avoid_recent="5"
        if [ -f "$CONFIG_FILE" ]; then
            wallpaper_dir=$(grep "WALLPAPER_DIR=" "$CONFIG_FILE" | cut -d'=' -f2)
            avoid_recent=$(grep "AVOID_RECENT=" "$CONFIG_FILE" | cut -d'=' -f2)
        fi

        print_color $YELLOW "当前壁纸目录：$wallpaper_dir"
        print_color $YELLOW "避免重复数量：$avoid_recent 张"
        echo ""
        print_color $WHITE " 1 更改壁纸目录"
        print_color $WHITE " 2 设置避免重复数量"
        print_color $WHITE " 3 重置所有配置"
        print_color $WHITE " 4 查看配置文件"
        print_color $CYAN "-----------------------------------------------"
        print_color $WHITE " 0 返回主菜单"
        echo -n "请输入对应数字 > "

        read choice
        case $choice in
            1)
                print_header
                print_color $WHITE "📁 更改壁纸目录"
                print_color $CYAN "-----------------------------------------------"
                print_color $YELLOW "当前目录：$wallpaper_dir"
                echo ""
                echo -n "请输入新的壁纸目录路径 > "
                read new_dir

                if [ -d "$new_dir" ]; then
                    sed -i "s|WALLPAPER_DIR=.*|WALLPAPER_DIR=$new_dir|" "$CONFIG_FILE"
                    print_color $GREEN "✅ 壁纸目录已更新为：$new_dir"
                else
                    print_color $RED "❌ 目录不存在：$new_dir"
                fi
                wait_key
                ;;
            2)
                print_header
                print_color $WHITE "🔢 设置避免重复数量"
                print_color $CYAN "-----------------------------------------------"
                print_color $YELLOW "当前设置：避免最近 $avoid_recent 张壁纸"
                echo ""
                echo "说明：设置为0表示完全随机，数字越大重复越少"
                echo -n "请输入新的数量 (0-20) > "
                read new_count

                if [[ "$new_count" =~ ^[0-9]+$ ]] && [ "$new_count" -ge 0 ] && [ "$new_count" -le 20 ]; then
                    sed -i "s/AVOID_RECENT=.*/AVOID_RECENT=$new_count/" "$CONFIG_FILE"
                    print_color $GREEN "✅ 避免重复数量已设置为：$new_count"
                else
                    print_color $RED "❌ 请输入0-20之间的数字"
                fi
                wait_key
                ;;
            3)
                print_header
                print_color $YELLOW "⚠️ 确认重置所有配置？这将清除历史记录 (y/N)"
                echo -n "> "
                read confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    rm -f "$CONFIG_FILE" "$CONFIG_DIR/history" "$PAUSE_FILE"
                    print_color $GREEN "✅ 配置已重置！"
                else
                    print_color $BLUE "ℹ️ 操作已取消"
                fi
                wait_key
                ;;
            4)
                print_header
                print_color $WHITE "📄 当前配置文件内容"
                print_color $CYAN "-----------------------------------------------"
                if [ -f "$CONFIG_FILE" ]; then
                    cat "$CONFIG_FILE"
                else
                    print_color $YELLOW "配置文件不存在"
                fi
                wait_key
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "❌ 无效选择，请重新输入！"
                sleep 1
                ;;
        esac
    done
}

# 🎯 函数：安装/卸载菜单
install_menu() {
    while true; do
        print_header
        print_color $WHITE "🔧 安装/卸载管理"
        print_color $CYAN "-----------------------------------------------"

        # 检查安装状态
        local install_status="未安装"
        if systemctl --user list-unit-files | grep -q "wallpaper-changer.timer"; then
            install_status="已安装"
        fi

        print_color $YELLOW "当前状态：$install_status"
        echo ""
        print_color $WHITE " 1 安装服务"
        print_color $WHITE " 2 重新安装"
        print_color $WHITE " 3 卸载服务"
        print_color $WHITE " 4 检查依赖"
        print_color $CYAN "-----------------------------------------------"
        print_color $WHITE " 0 返回主菜单"
        echo -n "请输入对应数字 > "

        read choice
        case $choice in
            1)
                print_header
                print_color $BLUE "🚀 安装壁纸更换服务..."
                echo ""
                "$INSTALL_SCRIPT" install
                wait_key
                ;;
            2)
                print_header
                print_color $BLUE "🔄 重新安装服务..."
                echo ""
                "$INSTALL_SCRIPT" uninstall
                sleep 2
                "$INSTALL_SCRIPT" install
                wait_key
                ;;
            3)
                print_header
                print_color $YELLOW "⚠️ 确认卸载服务？(y/N)"
                echo -n "> "
                read confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    "$INSTALL_SCRIPT" uninstall
                    print_color $GREEN "✅ 服务已卸载！"
                else
                    print_color $BLUE "ℹ️ 操作已取消"
                fi
                wait_key
                ;;
            4)
                print_header
                print_color $WHITE "🔍 检查系统依赖"
                print_color $CYAN "-----------------------------------------------"
                echo ""

                # 检查必要命令
                local deps=("systemctl" "gsettings" "find" "tail" "grep")
                for dep in "${deps[@]}"; do
                    if command -v "$dep" >/dev/null 2>&1; then
                        print_color $GREEN "✅ $dep - 已安装"
                    else
                        print_color $RED "❌ $dep - 未找到"
                    fi
                done

                echo ""
                # 检查桌面环境
                if [ -n "$XDG_CURRENT_DESKTOP" ]; then
                    print_color $GREEN "✅ 桌面环境：$XDG_CURRENT_DESKTOP"
                else
                    print_color $YELLOW "⚠️ 未检测到桌面环境"
                fi

                wait_key
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "❌ 无效选择，请重新输入！"
                sleep 1
                ;;
        esac
    done
}

# 🎯 主循环
main() {
    # 检查必要文件
    if [ ! -f "$WALLPAPER_SCRIPT" ] || [ ! -f "$INSTALL_SCRIPT" ]; then
        print_color $RED "❌ 错误：找不到必要的脚本文件！"
        print_color $YELLOW "请确保在正确的目录中运行此脚本"
        exit 1
    fi

    while true; do
        print_header
        show_main_menu

        read choice
        case $choice in
            1)
                start_service
                ;;
            2)
                toggle_pause
                ;;
            3)
                stop_service
                ;;
            4)
                rotation_mode_menu
                ;;
            5)
                change_wallpaper_now
                ;;
            6)
                show_status
                ;;
            7)
                log_management_menu
                ;;
            8)
                system_settings_menu
                ;;
            9)
                install_menu
                ;;
            0)
                print_header
                print_color $GREEN "👋 感谢使用智能壁纸更换器！"
                print_color $CYAN "🎨 愿你的桌面永远精彩！"
                exit 0
                ;;
            *)
                print_color $RED "❌ 无效选择，请重新输入！"
                sleep 1
                ;;
        esac
    done
}

# 🚀 启动脚本
main "$@"