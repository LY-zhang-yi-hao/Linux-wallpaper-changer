#!/bin/bash

# 🎨 自动壁纸更换脚本 v2.0
# 作者：为zyh定制
# 功能：智能壁纸更换系统，支持随机/顺序轮换、暂停/恢复、日志管理
# 支持的格式：jpg, jpeg, png, webp

# 📁 壁纸文件夹路径
WALLPAPER_DIR="$HOME/Pictures"

# 📝 日志文件路径
LOG_FILE="$HOME/.wallpaper_changer.log"

# 🔧 配置文件路径
CONFIG_DIR="$HOME/.config/wallpaper_changer"
CONFIG_FILE="$CONFIG_DIR/config"
HISTORY_FILE="$CONFIG_DIR/history"
PAUSE_FILE="$CONFIG_DIR/paused"

# 📊 日志管理配置
MAX_LOG_SIZE=1048576  # 1MB = 1024*1024 bytes
MAX_LOG_LINES=1000    # 最大日志行数
BACKUP_LOGS=3         # 保留的备份日志数量

# 🎯 轮换模式配置
ROTATION_MODE="random"  # random(随机) 或 sequential(顺序)
AVOID_RECENT=5          # 避免最近使用的壁纸数量

# 🎯 函数：初始化配置目录
init_config() {
    mkdir -p "$CONFIG_DIR"

    # 创建默认配置文件
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
# 🎨 壁纸更换器配置文件
ROTATION_MODE=random
AVOID_RECENT=5
WALLPAPER_DIR=$HOME/Pictures
EOF
    fi

    # 创建历史文件
    touch "$HISTORY_FILE"
}

# 🎯 函数：读取配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

# 🎯 函数：检查是否暂停
is_paused() {
    [ -f "$PAUSE_FILE" ]
}

# 🎯 函数：暂停服务
pause_service() {
    touch "$PAUSE_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S')" > "$PAUSE_FILE"
    log_message "⏸️ 壁纸更换服务已暂停"
    echo "⏸️ 壁纸更换服务已暂停"
}

# 🎯 函数：恢复服务
resume_service() {
    if [ -f "$PAUSE_FILE" ]; then
        rm -f "$PAUSE_FILE"
        log_message "▶️ 壁纸更换服务已恢复"
        echo "▶️ 壁纸更换服务已恢复"
    else
        echo "ℹ️ 服务当前未暂停"
    fi
}

# 🎯 函数：日志轮换
rotate_log() {
    if [ ! -f "$LOG_FILE" ]; then
        return 0
    fi

    # 检查文件大小
    local file_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)

    if [ "$file_size" -gt "$MAX_LOG_SIZE" ]; then
        # 备份当前日志
        for i in $(seq $((BACKUP_LOGS-1)) -1 1); do
            if [ -f "${LOG_FILE}.$i" ]; then
                mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
            fi
        done

        # 移动当前日志为备份
        mv "$LOG_FILE" "${LOG_FILE}.1"

        # 创建新的日志文件
        touch "$LOG_FILE"
        log_message "🔄 日志文件已轮换 (大小: ${file_size} bytes)"
    fi

    # 检查行数并清理
    local line_count=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$line_count" -gt "$MAX_LOG_LINES" ]; then
        # 保留最后的MAX_LOG_LINES行
        tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
        log_message "🧹 日志已清理，保留最近 $MAX_LOG_LINES 行"
    fi
}

# 🎯 函数：记录日志
log_message() {
    rotate_log
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 🎯 函数：检查壁纸文件夹是否存在
check_wallpaper_dir() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        log_message "❌ 错误：壁纸文件夹不存在: $WALLPAPER_DIR"
        exit 1
    fi
}

# 🎯 函数：获取所有支持的图片文件
get_image_files() {
    # 使用find命令查找所有支持的图片格式
    # -iname 表示忽略大小写
    find "$WALLPAPER_DIR" -type f \( \
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.png" -o \
        -iname "*.webp" \
    \) 2>/dev/null
}

# 🎯 函数：添加到历史记录
add_to_history() {
    local wallpaper_path="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S')|$(basename "$wallpaper_path")|$wallpaper_path" >> "$HISTORY_FILE"

    # 保持历史记录不超过100条
    if [ -f "$HISTORY_FILE" ]; then
        tail -n 100 "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
        mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    fi
}

# 🎯 函数：获取最近使用的壁纸
get_recent_wallpapers() {
    if [ -f "$HISTORY_FILE" ]; then
        tail -n "$AVOID_RECENT" "$HISTORY_FILE" | cut -d'|' -f3
    fi
}

# 🎯 函数：检查壁纸是否最近使用过
is_recently_used() {
    local wallpaper_path="$1"
    local recent_wallpapers
    mapfile -t recent_wallpapers < <(get_recent_wallpapers)

    for recent in "${recent_wallpapers[@]}"; do
        if [ "$wallpaper_path" = "$recent" ]; then
            return 0  # 最近使用过
        fi
    done
    return 1  # 没有最近使用过
}

# 🎯 函数：智能选择壁纸
select_wallpaper() {
    local image_files
    mapfile -t image_files < <(get_image_files)

    # 检查是否找到图片文件
    if [ ${#image_files[@]} -eq 0 ]; then
        log_message "❌ 错误：在 $WALLPAPER_DIR 中没有找到支持的图片文件"
        exit 1
    fi

    # 根据轮换模式选择壁纸
    case "$ROTATION_MODE" in
        "sequential")
            select_sequential_wallpaper "${image_files[@]}"
            ;;
        "random"|*)
            select_smart_random_wallpaper "${image_files[@]}"
            ;;
    esac
}

# 🎯 函数：顺序选择壁纸
select_sequential_wallpaper() {
    local image_files=("$@")
    local last_wallpaper=""

    # 获取最后使用的壁纸
    if [ -f "$HISTORY_FILE" ] && [ -s "$HISTORY_FILE" ]; then
        last_wallpaper=$(tail -n 1 "$HISTORY_FILE" | cut -d'|' -f3)
    fi

    # 如果没有历史记录，选择第一张
    if [ -z "$last_wallpaper" ]; then
        echo "${image_files[0]}"
        return
    fi

    # 找到上次使用的壁纸在数组中的位置
    for i in "${!image_files[@]}"; do
        if [ "${image_files[$i]}" = "$last_wallpaper" ]; then
            # 选择下一张，如果是最后一张则回到第一张
            local next_index=$(( (i + 1) % ${#image_files[@]} ))
            echo "${image_files[$next_index]}"
            return
        fi
    done

    # 如果没找到上次的壁纸（可能被删除了），选择第一张
    echo "${image_files[0]}"
}

# 🎯 函数：智能随机选择壁纸（避免最近使用的）
select_smart_random_wallpaper() {
    local image_files=("$@")
    local available_files=()

    # 如果图片数量少于等于避免数量，直接随机选择
    if [ ${#image_files[@]} -le "$AVOID_RECENT" ]; then
        local random_index=$((RANDOM % ${#image_files[@]}))
        echo "${image_files[$random_index]}"
        return
    fi

    # 筛选出没有最近使用的壁纸
    for file in "${image_files[@]}"; do
        if ! is_recently_used "$file"; then
            available_files+=("$file")
        fi
    done

    # 如果没有可用的文件，从所有文件中随机选择
    if [ ${#available_files[@]} -eq 0 ]; then
        available_files=("${image_files[@]}")
    fi

    # 随机选择
    local random_index=$((RANDOM % ${#available_files[@]}))
    echo "${available_files[$random_index]}"
}

# 🎯 函数：设置壁纸
set_wallpaper() {
    local wallpaper_path="$1"

    # 检查文件是否存在
    if [ ! -f "$wallpaper_path" ]; then
        log_message "❌ 错误：壁纸文件不存在: $wallpaper_path"
        return 1
    fi

    # 使用gsettings设置壁纸（适用于Unity/GNOME）
    gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"

    # 检查设置是否成功
    if [ $? -eq 0 ]; then
        # 添加到历史记录
        add_to_history "$wallpaper_path"
        log_message "✅ 成功设置壁纸 [$ROTATION_MODE]: $(basename "$wallpaper_path")"
        return 0
    else
        log_message "❌ 设置壁纸失败: $wallpaper_path"
        return 1
    fi
}

# 🎯 函数：显示脚本信息
show_info() {
    local image_count=$(get_image_files | wc -l)
    local pause_status="运行中"

    if is_paused; then
        pause_status="已暂停 ($(cat "$PAUSE_FILE"))"
    fi

    echo "🎨 自动壁纸更换脚本 v2.0"
    echo "📁 壁纸目录: $WALLPAPER_DIR"
    echo "🖼️ 图片数量: $image_count 张"
    echo "🔄 轮换模式: $ROTATION_MODE"
    echo "⏸️ 服务状态: $pause_status"
    echo "📝 日志文件: $LOG_FILE"
    echo "⏰ 更换间隔: 每5分钟"
    echo ""
}

# 🎯 函数：显示状态信息
show_status() {
    show_info

    echo "📊 最近使用的壁纸："
    if [ -f "$HISTORY_FILE" ] && [ -s "$HISTORY_FILE" ]; then
        while IFS='|' read -r timestamp filename filepath; do
            echo "  $timestamp - $filename"
        done < <(tail -n 5 "$HISTORY_FILE")
    else
        echo "  暂无历史记录"
    fi
    echo ""
}

# 🎯 函数：清理日志
clean_logs() {
    echo "🧹 开始清理日志文件..."

    # 备份当前日志
    if [ -f "$LOG_FILE" ]; then
        cp "$LOG_FILE" "${LOG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "✅ 已备份当前日志"
    fi

    # 清空主日志文件
    > "$LOG_FILE"
    log_message "🧹 日志文件已清理"

    # 删除旧的备份日志
    find "$(dirname "$LOG_FILE")" -name "$(basename "$LOG_FILE").backup.*" -mtime +7 -delete 2>/dev/null
    find "$(dirname "$LOG_FILE")" -name "$(basename "$LOG_FILE").[0-9]*" -delete 2>/dev/null

    echo "✅ 日志清理完成"
}

# 🎯 主函数
main() {
    # 初始化配置
    init_config
    load_config

    # 处理命令行参数
    case "$1" in
        "--info")
            show_info
            exit 0
            ;;
        "--status")
            show_status
            exit 0
            ;;
        "--pause")
            pause_service
            exit 0
            ;;
        "--resume")
            resume_service
            exit 0
            ;;
        "--clean-logs")
            clean_logs
            exit 0
            ;;
        "--mode")
            if [ -n "$2" ] && [[ "$2" =~ ^(random|sequential)$ ]]; then
                sed -i "s/ROTATION_MODE=.*/ROTATION_MODE=$2/" "$CONFIG_FILE"
                echo "🔄 轮换模式已设置为: $2"
                log_message "🔄 轮换模式已更改为: $2"
            else
                echo "❌ 错误：请指定有效的模式 (random 或 sequential)"
                exit 1
            fi
            exit 0
            ;;
        "--test")
            show_info
            echo "🧪 测试模式：立即更换一次壁纸"
            echo ""
            ;;
        "--help")
            echo "🎨 自动壁纸更换脚本 v2.0 - 使用帮助"
            echo ""
            echo "用法: $0 [选项]"
            echo ""
            echo "选项："
            echo "  --info          显示脚本信息"
            echo "  --status        显示详细状态"
            echo "  --pause         暂停壁纸更换"
            echo "  --resume        恢复壁纸更换"
            echo "  --clean-logs    清理日志文件"
            echo "  --mode MODE     设置轮换模式 (random/sequential)"
            echo "  --test          测试壁纸更换"
            echo "  --help          显示此帮助"
            echo ""
            exit 0
            ;;
    esac

    # 检查是否暂停
    if is_paused; then
        log_message "⏸️ 服务已暂停，跳过壁纸更换"
        exit 0
    fi

    # 检查壁纸文件夹
    check_wallpaper_dir

    # 选择壁纸
    local selected_wallpaper
    selected_wallpaper=$(select_wallpaper)

    if [ -n "$selected_wallpaper" ]; then
        # 设置壁纸
        set_wallpaper "$selected_wallpaper"

        # 如果是测试模式，显示结果
        if [ "$1" = "--test" ]; then
            echo "🎯 选中的壁纸: $(basename "$selected_wallpaper")"
            echo "📝 查看日志: tail -f $LOG_FILE"
        fi
    else
        log_message "❌ 错误：无法选择壁纸"
        exit 1
    fi
}

# 🚀 启动脚本
log_message "🚀 壁纸更换脚本启动"
main "$@"
