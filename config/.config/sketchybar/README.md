## Dependencies

- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Hack Nerd Font](https://formulae.brew.sh/cask/font-hack-nerd-font)
- [Iosevka Nerd Font](https://formulae.brew.sh/cask/font-iosevka-nerd-font)

## Bluetooth Battery Plugin

The `bt_battery` plugin displays battery levels for Bluetooth headphones. It uses a custom Objective-C helper to access private IOBluetooth APIs, since `system_profiler` doesn't report battery levels for all Bluetooth audio devices.

### How It Works

macOS exposes Bluetooth device battery information through private methods in the `IOBluetooth.framework`:
- `batteryPercentSingle` - Returns battery level for single-battery devices
- `batteryPercentLeft/Right` - For devices with separate left/right batteries (e.g., AirPods)
- `batteryPercentCase` - For charging case battery levels

The standard `system_profiler SPBluetoothDataType` command only shows battery info for Apple devices and some other manufacturers. For devices like Nothing Headphones, we need to access the private `IOBluetoothDevice` methods directly.

### Compilation

The helper binary needs to be compiled from source:

```bash
cd plugins
clang -framework IOBluetooth -framework Foundation bt_battery_helper.m -o bt_battery_helper
```

### Files

- `plugins/bt_battery_helper.m` - Objective-C source that queries IOBluetooth APIs
- `plugins/bt_battery_helper` - Compiled binary (must be executable)
- `plugins/bt_battery.sh` - Shell script that calls the helper and updates sketchybar

### Usage

The shell script is called by sketchybar with the `$NAME` environment variable set to the item name. It:
1. Calls `bt_battery_helper` with the device name to search for
2. Hides the item if the device is disconnected or has no battery info
3. Selects an appropriate battery icon based on the percentage
4. Updates the sketchybar item with the icon and battery percentage

To modify for a different device, change the device name in `bt_battery.sh`:
```bash
PERCENTAGE="$("$SCRIPT_DIR/bt_battery_helper" "Your Device Name" 2>/dev/null)"
```
