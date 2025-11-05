#import <IOBluetooth/IOBluetooth.h>
#import <Foundation/Foundation.h>

// Declare private battery methods
@interface IOBluetoothDevice (PrivateBattery)
- (NSInteger)batteryPercentSingle;
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "Usage: %s <device_name>\n", argv[0]);
            return 1;
        }

        NSString *searchName = [NSString stringWithUTF8String:argv[1]];
        NSArray *devices = [IOBluetoothDevice pairedDevices];

        for (IOBluetoothDevice *device in devices) {
            NSString *deviceName = [device name];
            if (deviceName && [deviceName containsString:searchName]) {
                // Check if connected
                if (![device isConnected]) {
                    return 1; // Not connected
                }

                // Get battery level
                NSInteger battery = [device batteryPercentSingle];
                if (battery > 0) {
                    printf("%ld\n", (long)battery);
                    return 0;
                }

                return 1; // No battery info
            }
        }

        return 1; // Device not found
    }
}
