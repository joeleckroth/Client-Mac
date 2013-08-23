//
//  AppDelegate.h
//  Dewdrop
//
//  Created by Dino Angelov on 8/20/13.
//  Copyright (c) 2013 Dino Angelov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DADropStatus.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusImageHighlighted;
    NSOperationQueue *queue;
    DADropStatus *dropView;
    __weak NSMenu *_menu;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSTextField *dewdropServer;
@property (weak) IBOutlet NSTextField *dewdropUsername;
@property (weak) IBOutlet NSSecureTextField *dewdropPassword;
@property (weak) IBOutlet NSButton *verifyButton;
@property (weak) IBOutlet NSProgressIndicator *verifyProgressIndicator;
@property (weak) IBOutlet NSButton *launchOnLogin;

- (void)startUpload:(NSArray *)files;
- (IBAction)verifyDetails:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)setAppLaunchOnLogin:(id)sender;

@end