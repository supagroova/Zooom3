#import <Cocoa/Cocoa.h>

@class AccessibilityOnboardingBridge;

@interface EMRAppDelegate : NSObject <NSApplicationDelegate, NSPopoverDelegate> {
    NSStatusItem * statusItem;
    int keyModifierFlags;
    int resizeKeyModifierFlags;
    int cachedMoveMouseButton;
    int cachedResizeMouseButton;
    BOOL cachedHasConflict;
    NSRunningApplication *lastApp;

    NSPopover *popover;
    id popoverEventMonitor;

    BOOL cachedHoverModeEnabled;
    AccessibilityOnboardingBridge *onboardingBridge;
}

- (int)modifierFlags;
- (int)resizeModifierFlags;
- (int)moveMouseButton;
- (int)resizeMouseButton;

@property (nonatomic) BOOL sessionActive;
@property float moveFilterInterval;
@property float resizeFilterInterval;

@end
