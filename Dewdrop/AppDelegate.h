//
//  AppDelegate.h
//  Dewdrop
//
//  Created by Dino Angelov on 8/20/13.
//  Copyright (c) 2013 Dino Angelov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatusItemView.h"
#import "RequestQueue.h"
#import "LaunchAtLoginController.h"
#import "Finder.h"
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    NSOperationQueue *queue;
    NSString *lastUploadURL;
    
@private;
    StatusItemView *statusItem;
    StatusItemView *_statusItemView;
}


@property (nonatomic, readonly) StatusItemView *statusItem;
@property (nonatomic, readonly) StatusItemView *statusItemView;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSTextField *dewdropServer;
@property (weak) IBOutlet NSTextField *dewdropUsername;
@property (weak) IBOutlet NSSecureTextField *dewdropPassword;
@property (weak) IBOutlet NSButton *verifyButton;
@property (weak) IBOutlet NSProgressIndicator *verifyProgressIndicator;
@property (weak) IBOutlet NSButton *launchOnLogin;
@property (weak) IBOutlet MASShortcutView *shortcutView;

- (void)startUpload:(NSArray *)files;
- (void)copyLastUploadURL;
- (IBAction)verifyDetails:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)setAppLaunchOnLogin:(id)sender;
- (IBAction)uploadFinderSelection:(id)sender;

@end