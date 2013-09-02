#import "StatusItemView.h"
#import "AppDelegate.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -


- (void)setMenu:(NSMenu *)menu {
     _menu = menu;
    [_menu setDelegate:self];
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //register for drags
        NSArray *dragTypes = [NSArray arrayWithObjects:NSURLPboardType, NSFileContentsPboardType, NSFilenamesPboardType, nil];
        [self registerForDraggedTypes:dragTypes];
    }
    
    return self;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem {
    CGFloat itemWidth = [[NSStatusBar systemStatusBar] thickness];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [self initWithFrame:itemRect];
    
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    
    return self;
}

- (void)dealloc{
    
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect {
	float rectangleSize = 15;
    
    NSRect offscreenRect = NSMakeRect(4.0, 4.0, rectangleSize, rectangleSize);
    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRoundedRect:offscreenRect xRadius:3 yRadius:3];
    
    if (_isHighlighted){
        [[NSColor selectedMenuItemColor] set];
        NSBezierPath *selectedRect = [NSBezierPath bezierPathWithRect:dirtyRect];
        [selectedRect fill];
    }
    
    [[NSColor blackColor] set];
    [textViewSurround stroke];
    if (_isHovered){
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

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent {
    // Hide the "Upload Finder selection" menu item if there is no selection in Finder
    FinderApplication * finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
    SBElementArray * selection = [[finder selection] get];
    NSArray * items = [selection arrayByApplyingSelector:@selector(URL)];
    if ([items count] < 1){
        [[_menu itemWithTag:11] setHidden:YES];
    } else {
        [[_menu itemWithTag:11] setHidden:NO];
    }
    
    [_statusItem popUpStatusItemMenu:_menu];
    [NSApp sendAction:self.action to:self.target from:self];
}

- (void)rightMouseDown:(NSEvent *)theEvent{
    [self setHighlighted:YES];
    [self setNeedsDisplay:YES];
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] copyLastUploadURL];
    [self setHighlighted:NO];
    [self setNeedsDisplay:YES];
}


- (void)menuWillOpen:(NSMenu *)menu {
    [self setHighlighted:YES];
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    [self setHighlighted:NO];
    [self setNeedsDisplay:YES];
}



#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    _image = newImage;
    [self setNeedsDisplay:YES];
}

- (void)setAlternateImage:(NSImage *)newImage
{
    _alternateImage = newImage;
    if (self.isHighlighted)
        [self setNeedsDisplay:YES];
}


#pragma mark Dragging operations
// If we can drop this type of file, highlight the icon
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]) {
        _isHovered = YES;
        [self setNeedsDisplay:YES];
        
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender {
    _isHovered = NO;
    [self setNeedsDisplay:YES];
}

//perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    _isHovered = NO;
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

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
