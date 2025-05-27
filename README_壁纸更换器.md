# 🎨 自动壁纸更换器 v2.0

一个为Ubuntu 20.04 Unity桌面环境定制的智能壁纸更换系统，支持多种轮换模式、暂停/恢复功能和智能日志管理。

## ✨ 功能特点

### 🔄 **智能轮换系统**
- **随机模式**：智能避免最近使用的壁纸，确保多样性
- **顺序模式**：按文件顺序依次更换，永不重复
- **动态切换**：随时切换轮换模式

### ⏸️ **灵活控制**
- **暂停/恢复**：随时暂停或恢复壁纸更换
- **即时测试**：立即测试壁纸更换效果
- **状态监控**：实时查看服务状态和历史记录

### 📝 **智能日志管理**
- **自动轮换**：日志文件超过1MB自动备份
- **大小限制**：保持最近1000行日志记录
- **一键清理**：快速清理所有日志文件

### 🎯 **其他特性**
- 🖼️ **多格式支持**：支持jpg, jpeg, png, webp格式
- 🚀 **开机自启**：系统启动后自动开始工作
- 📊 **详细统计**：显示图片数量和使用历史
- 🎨 **友好界面**：彩色输出和emoji图标

## 📁 文件说明

### 🎯 **核心文件**
- `wallpaper_changer.sh` - 主脚本，负责智能选择和设置壁纸
- `wallpaper_menu.sh` - **交互式管理界面** (推荐使用)
- `install_wallpaper_changer.sh` - 传统命令行管理脚本
- `wallpaper` - 快捷启动脚本

### ⚙️ **系统文件**
- `wallpaper-changer.service` - systemd服务配置文件
- `wallpaper-changer.timer` - systemd定时器配置文件
- `wallpaper_manager` - 全局快捷管理脚本

## 🚀 快速开始

### 🎯 **推荐方式：交互式界面**
```bash
# 启动友好的交互式管理界面
./wallpaper_menu.sh

# 或使用快捷命令
./wallpaper
```

**界面预览：**
```
-----------------------------------------------
🎨 欢迎使用智能壁纸更换器！    版本：v2.0
壁纸服务正在运行（random模式），图片数量：76张
当前壁纸目录：~/Pictures
GitHub：https://github.com/your-repo/wallpaper-changer
-----------------------------------------------
 1 启动/重启服务
 2 暂停/恢复服务
 3 停止服务
 4 轮换模式设置
 5 立即更换壁纸
 6 查看详细状态
 7 日志管理
 8 系统设置
 9 安装/卸载
-----------------------------------------------
 0 退出脚本
请输入对应数字 >
```

### 📋 **传统命令行方式**
```bash
# 安装服务
./install_wallpaper_changer.sh install

# 查看状态
./install_wallpaper_changer.sh status

# 测试功能
./install_wallpaper_changer.sh test
```

## 🛠️ 管理命令

### 📋 **基本操作**
```bash
# 安装并启动服务
./install_wallpaper_changer.sh install

# 启动/停止服务
./install_wallpaper_changer.sh start
./install_wallpaper_changer.sh stop

# 查看状态
./install_wallpaper_changer.sh status

# 测试功能
./install_wallpaper_changer.sh test

# 卸载服务
./install_wallpaper_changer.sh uninstall
```

### 🎛️ **高级功能**
```bash
# 暂停/恢复壁纸更换
./install_wallpaper_changer.sh pause
./install_wallpaper_changer.sh resume

# 设置轮换模式
./install_wallpaper_changer.sh mode random      # 随机模式
./install_wallpaper_changer.sh mode sequential  # 顺序模式

# 日志管理
./install_wallpaper_changer.sh clean-logs       # 清理日志

# 详细状态信息
./install_wallpaper_changer.sh info

# 显示帮助
./install_wallpaper_changer.sh help
```

### 🔧 **直接脚本命令**
```bash
# 直接使用主脚本
./wallpaper_changer.sh --test          # 测试更换
./wallpaper_changer.sh --status        # 详细状态
./wallpaper_changer.sh --pause         # 暂停服务
./wallpaper_changer.sh --resume        # 恢复服务
./wallpaper_changer.sh --clean-logs    # 清理日志
./wallpaper_changer.sh --mode random   # 设置模式
./wallpaper_changer.sh --help          # 显示帮助
```

## 📝 日志查看

### 查看壁纸更换日志
```bash
tail -f ~/.wallpaper_changer.log
```

### 查看服务日志
```bash
tail -f ~/.wallpaper_service.log
```

### 查看systemd日志
```bash
journalctl --user -u wallpaper-changer.timer -f
```

## ⚙️ 配置说明

### 更改壁纸文件夹
编辑 `wallpaper_changer.sh` 文件中的 `WALLPAPER_DIR` 变量：
```bash
WALLPAPER_DIR="$HOME/Pictures"  # 改为你的壁纸文件夹路径
```

### 更改更换间隔
编辑 `wallpaper-changer.timer` 文件中的 `OnUnitActiveSec` 设置：
```ini
OnUnitActiveSec=5min  # 改为你想要的间隔时间
```

修改后需要重新安装服务：
```bash
./install_wallpaper_changer.sh uninstall
./install_wallpaper_changer.sh install
```

## 🔧 故障排除

### 服务无法启动
1. 检查脚本权限：`chmod +x wallpaper_changer.sh`
2. 检查壁纸文件夹是否存在：`ls ~/Pictures`
3. 查看详细错误：`systemctl --user status wallpaper-changer.timer`

### 壁纸没有更换
1. 检查是否有支持的图片文件：`ls ~/Pictures/*.{jpg,jpeg,png,webp}`
2. 手动测试脚本：`./wallpaper_changer.sh --test`
3. 查看日志：`tail ~/.wallpaper_changer.log`

### 开机不自启
确保服务已启用：
```bash
systemctl --user enable wallpaper-changer.timer
```

## 📊 系统要求

- Ubuntu 20.04 LTS
- Unity桌面环境
- systemd用户服务支持
- 至少一张支持格式的图片在~/Pictures文件夹中

## 🎯 技术实现

- **脚本语言**：Bash
- **服务管理**：systemd用户服务
- **壁纸设置**：gsettings (GNOME/Unity)
- **定时执行**：systemd timer
- **日志记录**：自定义日志文件

## 📞 支持

如果遇到问题，请：
1. 查看日志文件
2. 运行测试命令
3. 检查服务状态
4. 确认系统环境符合要求

---

🎨 **享受你的动态桌面壁纸吧！** ✨
