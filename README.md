# 🎨 Linux Wallpaper Changer v2.0

An intelligent wallpaper changing system designed for Ubuntu 20.04 Unity desktop environment, featuring multiple rotation modes, pause/resume functionality, and smart log management.

## ✨ Features

### 🔄 **Smart Rotation System**
- **Random Mode**: Intelligently avoids recently used wallpapers to ensure diversity
- **Sequential Mode**: Changes wallpapers in file order, never repeating
- **Dynamic Switching**: Switch between rotation modes anytime

### ⏸️ **Flexible Control**
- **Pause/Resume**: Pause or resume wallpaper changing anytime
- **Instant Test**: Immediately test wallpaper changing effects
- **Status Monitoring**: Real-time service status and history viewing

### 📝 **Smart Log Management**
- **Auto Rotation**: Automatically backup logs when file exceeds 1MB
- **Size Limit**: Keep the most recent 1000 log entries
- **One-click Cleanup**: Quick cleanup of all log files

### 🎯 **Other Features**
- 🖼️ **Multi-format Support**: Supports jpg, jpeg, png, webp formats
- 🚀 **Auto-start**: Automatically starts after system boot
- 📊 **Detailed Statistics**: Shows image count and usage history
- 🎨 **Friendly Interface**: Colorful output and emoji icons

## 📁 File Structure

### 🎯 **Core Files**
- `wallpaper_changer.sh` - Main script for intelligent wallpaper selection and setting
- `wallpaper_menu.sh` - **Interactive Management Interface** (Recommended)
- `install_wallpaper_changer.sh` - Traditional command-line management script
- `wallpaper` - Quick launch script

### ⚙️ **System Files**
- `wallpaper-changer.service` - systemd service configuration file
- `wallpaper-changer.timer` - systemd timer configuration file
- `wallpaper_manager` - Global quick management script

## 🚀 Quick Start

### 🎯 **Recommended: Interactive Interface**
```bash
# Launch the friendly interactive management interface
./wallpaper_menu.sh

# Or use the quick command
./wallpaper
```

**Interface Preview:**
```
-----------------------------------------------
🎨 Welcome to Smart Wallpaper Changer!    Version: v2.0
Wallpaper service running (random mode), Images: 76
Current wallpaper directory: ~/Pictures
GitHub: https://github.com/LY-zhang-yi-hao/Linux-wallpaper-changer
-----------------------------------------------
 1 Start/Restart Service
 2 Pause/Resume Service
 3 Stop Service
 4 Rotation Mode Settings
 5 Change Wallpaper Now
 6 View Detailed Status
 7 Log Management
 8 System Settings
 9 Install/Uninstall
-----------------------------------------------
 0 Exit Script
Please enter the corresponding number >
```

### 📋 **Traditional Command Line**
```bash
# Install service
./install_wallpaper_changer.sh install

# View status
./install_wallpaper_changer.sh status

# Test functionality
./install_wallpaper_changer.sh test
```

## 🛠️ Management Commands

### 📋 **Basic Operations**
```bash
# Install and start service
./install_wallpaper_changer.sh install

# Start/stop service
./install_wallpaper_changer.sh start
./install_wallpaper_changer.sh stop

# View status
./install_wallpaper_changer.sh status

# Test functionality
./install_wallpaper_changer.sh test

# Uninstall service
./install_wallpaper_changer.sh uninstall
```

### 🎛️ **Advanced Features**
```bash
# Pause/resume wallpaper changing
./install_wallpaper_changer.sh pause
./install_wallpaper_changer.sh resume

# Set rotation mode
./install_wallpaper_changer.sh mode random      # Random mode
./install_wallpaper_changer.sh mode sequential  # Sequential mode

# Log management
./install_wallpaper_changer.sh clean-logs       # Clean logs

# Detailed status information
./install_wallpaper_changer.sh info

# Show help
./install_wallpaper_changer.sh help
```

### 🔧 **Direct Script Commands**
```bash
# Use main script directly
./wallpaper_changer.sh --test          # Test change
./wallpaper_changer.sh --status        # Detailed status
./wallpaper_changer.sh --pause         # Pause service
./wallpaper_changer.sh --resume        # Resume service
./wallpaper_changer.sh --clean-logs    # Clean logs
./wallpaper_changer.sh --mode random   # Set mode
./wallpaper_changer.sh --help          # Show help
```

## 📝 Log Viewing

### View wallpaper change logs
```bash
tail -f ~/.wallpaper_changer.log
```

### View service logs
```bash
tail -f ~/.wallpaper_service.log
```

### View systemd logs
```bash
journalctl --user -u wallpaper-changer.timer -f
```

## ⚙️ Configuration

### Change wallpaper directory
Edit the `WALLPAPER_DIR` variable in `wallpaper_changer.sh`:
```bash
WALLPAPER_DIR="$HOME/Pictures"  # Change to your wallpaper directory path
```

### Change rotation interval
Edit the `OnUnitActiveSec` setting in `wallpaper-changer.timer`:
```ini
OnUnitActiveSec=5min  # Change to your desired interval
```

After modification, reinstall the service:
```bash
./install_wallpaper_changer.sh uninstall
./install_wallpaper_changer.sh install
```

## 🔧 Troubleshooting

### Service won't start
1. Check script permissions: `chmod +x wallpaper_changer.sh`
2. Check if wallpaper directory exists: `ls ~/Pictures`
3. View detailed errors: `systemctl --user status wallpaper-changer.timer`

### Wallpaper not changing
1. Check for supported image files: `ls ~/Pictures/*.{jpg,jpeg,png,webp}`
2. Test script manually: `./wallpaper_changer.sh --test`
3. View logs: `tail ~/.wallpaper_changer.log`

### Auto-start not working
Ensure service is enabled:
```bash
systemctl --user enable wallpaper-changer.timer
```

## 📊 System Requirements

- Ubuntu 20.04 LTS
- Unity desktop environment
- systemd user service support
- At least one supported format image in ~/Pictures directory

## 🎯 Technical Implementation

- **Script Language**: Bash
- **Service Management**: systemd user service
- **Wallpaper Setting**: gsettings (GNOME/Unity)
- **Scheduled Execution**: systemd timer
- **Log Recording**: Custom log files

## 📞 Support

If you encounter problems, please:
1. Check log files
2. Run test commands
3. Check service status
4. Confirm system environment meets requirements

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

🎨 **Enjoy your dynamic desktop wallpapers!** ✨
