//
//  DADropStatus.h
//  Dewdrop
//
//  Created by Dino Angelov on 8/20/13.
//  Copyright (c) 2013 Dino Angelov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DADropStatus : NSView <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
{
    // Highlight the drop zone
    BOOL hovered;
}

@property (assign) float progress;
@property (assign) BOOL working;

- (id)initWithFrame:(NSRect)frame;

@end
