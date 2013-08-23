#import "DADropStatus.h"
#import "AppDelegate.h"

@implementation DADropStatus : NSView

- (id)initWithFrame:(NSRect)frame
{
    hovered = NO;
    _progress = 0.0f;
    _working = NO;
    
    self = [super initWithFrame:frame];
    if (self) {
        // Register for drags
        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    float rectangleSize = 14;
    
    NSRect offscreenRect = NSMakeRect(4.0, 4.0, rectangleSize, rectangleSize);
    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRoundedRect:offscreenRect xRadius:3 yRadius:3];
    
    [[NSColor blackColor] set];
    [textViewSurround stroke];
    if (hovered){
        [[NSColor alternateSelectedControlColor] set];
        [textViewSurround fill];
    }
    
    if (_working){
        float progressSize = _progress * rectangleSize;
        NSRect progressRect = NSMakeRect(4.0, 4.0, rectangleSize, progressSize);
        NSBezierPath *progressView = [NSBezierPath bezierPathWithRoundedRect:progressRect xRadius:3 yRadius:3];
        [progressView fill];
    }
}


#pragma mark Dragging operations
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    hovered = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    hovered = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    hovered = NO;
    [self setNeedsDisplay:YES];
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        [(AppDelegate *)[[NSApplication sharedApplication] delegate] startUpload:files];
    }
    return YES;
}

#pragma mark Satisfy NSPasteboardItemDataProvider implementation
- (void)pasteboard:(NSPasteboard *)pasteboard item:(NSPasteboardItem *)item provideDataForType:(NSString *)type {
    
}


@end