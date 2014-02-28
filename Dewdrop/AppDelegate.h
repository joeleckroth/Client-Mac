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

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMetadataQueryDelegate> {
    NSOperationQueue *queue;
    NSString *lastUploadURL;
    
@private;
    StatusItemView *statusItem;
    StatusItemView *_statusItemView;
    NSMetadataQuery *query;
    NSTimeInterval lastUploadOperationDate;
}

@property (strong) id activity;
@property (nonatomic, readonly) StatusItemView *statusItem;
@property (nonatomic, readonly) StatusItemView *statusItemView;
@property (nonatomic, copy) NSArray *queryResults;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSTextField *dewdropServer;
@property (weak) IBOutlet NSTextField *dewdropUsername;
@property (weak) IBOutlet NSSecureTextField *dewdropPassword;
@property (weak) IBOutlet NSButton *verifyButton;
@property (weak) IBOutlet NSProgressIndicator *verifyProgressIndicator;
@property (weak) IBOutlet NSButton *launchOnLogin;
@property (weak) IBOutlet MASShortcutView *shortcutView;
@property (weak) IBOutlet NSButton *checkboxWeeklyUpdatesCheck;
@property (weak) IBOutlet NSButton *checkboxAutoUploadScreenshots;
@property (weak) IBOutlet NSButton *checkboxRemoveScreenshotsAfterUpload;

- (void)startUpload:(NSArray *)files deleteAfterUploading:(BOOL)delete;
- (void)copyLastUploadURL;
- (NSString *)getLastUploadURL;
- (IBAction)verifyDetails:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)setAppLaunchOnLogin:(id)sender;
- (IBAction)uploadFinderSelection:(id)sender;
- (IBAction)toggleAutoScreenshotUpload:(id)sender;

@end