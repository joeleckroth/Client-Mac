//
//  AppDelegate.m
//  Dewdrop
//
//  Created by Dino Angelov on 8/20/13.
//  Copyright (c) 2013 Dino Angelov. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusItemView = _statusItemView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Install icon into the menu bar
    NSStatusItem *stockStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
    _statusItemView = [[StatusItemView alloc] initWithStatusItem:stockStatusItem];
    [_statusItemView setMenu:_menu];
    
    if ([NSUserNotification class] && [NSUserNotificationCenter class]){
		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
	}
    
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [_launchOnLogin setState:launch];
    
    self.shortcutView.associatedUserDefaultsKey = @"GlobalShortcut";
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:@"GlobalShortcut" handler:^{
        [self uploadFinderSelection:self];
    }];
    
    lastUploadURL = @"";
}

- (void)startUpload:(NSArray *)files {
    
    id obj = [files objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"%@", obj];
    filename = [filename stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filename];
    
    if (imageData == nil)
        return;
    
    NSString *urlString = [_dewdropServer stringValue];
    if ( (![urlString hasPrefix:@"http://"]) && (![urlString hasPrefix:@"https://"]) ) {
        urlString = [@"http://" stringByAppendingString:urlString];
    }
    urlString = [urlString stringByAppendingString:@"?action=upload"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------dewdrop648898021";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    // Name of file
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[filename dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Username
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[_dewdropUsername stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Password
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[_dewdropPassword stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Prepare the file to be sent
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\".jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];
    
    RQOperation *operation = [RQOperation operationWithRequest:request];
    
    // Completion handler
    operation.completionHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        
        _statusItemView.working = NO;
        [_statusItemView setNeedsDisplay:YES];
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!error) {
            [[NSPasteboard generalPasteboard] clearContents];
            [[NSPasteboard generalPasteboard] setString:returnString forType:NSStringPboardType];
            lastUploadURL = returnString;
            // Send a notification to notification center, if it's available
            [[NSSound soundNamed:@"Pop"] play];
            if ([NSUserNotification class] && [NSUserNotificationCenter class]){
                
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = @"Upload finished!";
                notification.informativeText = returnString;
                notification.hasActionButton = NO;
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
        } else {
            // Send a notification to notification center, if it's available
            [[NSSound soundNamed:@"Submarine"] play];
            if ([NSUserNotification class] && [NSUserNotificationCenter class]){
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = @"Upload failed!";
                notification.informativeText = returnString;
                notification.hasActionButton = NO;
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
        }
            
    };
    
    // Progress handler
    operation.uploadProgressHandler = ^(float progress, NSInteger bytesTransferred, NSInteger totalBytes) {
        
        NSLog(@"%f", progress);
        _statusItemView.progress = progress;
        if (progress < 1){
            _statusItemView.working = YES;
        }
        
        [_statusItemView setNeedsDisplay:YES];
        
    };
    _statusItemView.working = YES;
    [_statusItemView setNeedsDisplay:YES];
    
    // Add operation to queue
    [[RequestQueue mainQueue] addOperation:operation];
    

}

- (IBAction)verifyDetails:(id)sender {
    
    NSString *urlString = [_dewdropServer stringValue];
    if ( (![urlString hasPrefix:@"http://"]) && (![urlString hasPrefix:@"https://"]) ) {
        urlString = [@"http://" stringByAppendingString:urlString];
    }
    urlString = [urlString stringByAppendingString:@"?action=verify"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------dewdrop648898021";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    // Username
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[_dewdropUsername stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Password
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[_dewdropPassword stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    RQOperation *operation = [RQOperation operationWithRequest:request];
    [_verifyProgressIndicator setHidden:NO];
    [_verifyProgressIndicator startAnimation:_verifyProgressIndicator];
    [_verifyButton setEnabled:NO];
    
    // Completion handler
    operation.completionHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [_verifyProgressIndicator setHidden:YES];
        [_verifyButton setEnabled:YES];
        
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!error) {
            NSRunAlertPanel(@"Success", @"You have correctly setup Dewdrop and you're ready to go.", @"OK", nil, nil);
        } else {
            NSRunAlertPanel(@"Failure", returnString, @"OK", nil, nil);
        }
        
    };
    
    // Add operation to queue
    [[RequestQueue mainQueue] addOperation:operation];
}

- (IBAction)openPreferences:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:_window];
}

- (IBAction)setAppLaunchOnLogin:(id)sender {
    if ([_launchOnLogin state] == 1){
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        [launchController setLaunchAtLogin:YES];
    } else {
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        [launchController setLaunchAtLogin:NO];
    }
}

- (IBAction)uploadFinderSelection:(id)sender {
    FinderApplication * finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
    SBElementArray * selection = [[finder selection] get];
    
    NSArray * items = [selection arrayByApplyingSelector:@selector(URL)];
    [self startUpload:items];
}

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

- (void)copyLastUploadURL {
    if ([lastUploadURL isEqualToString:@""]){
        
    } else {
        [[NSSound soundNamed:@"Pop"] play];
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:lastUploadURL forType:NSStringPboardType];
    }
}

@end
