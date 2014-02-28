#import "StatusItemView.h"
#import "AppDelegate.h"

@implementation StatusItemView

#pragma mark Properties
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

    _progress = 0;
    
    return self;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem {
    CGFloat itemWidth = [[statusItem view] frame].size.width;
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

    //// Color Declarations
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
    if (_isHighlighted) {
        strokeColor = [NSColor selectedMenuItemColor];
    }

    //// tab Drawing
    NSBezierPath* tabPath = [NSBezierPath bezierPath];
    [tabPath moveToPoint: NSMakePoint(0, 27)];
    [tabPath lineToPoint: NSMakePoint(0, 23.6)];
    [tabPath curveToPoint: NSMakePoint(9.48, 18.49) controlPoint1: NSMakePoint(0, 23.6) controlPoint2: NSMakePoint(9.37, 22.75)];
    [tabPath curveToPoint: NSMakePoint(9.48, 8.29) controlPoint1: NSMakePoint(9.59, 14.24) controlPoint2: NSMakePoint(9.48, 8.29)];
    [tabPath curveToPoint: NSMakePoint(15.25, 4.04) controlPoint1: NSMakePoint(9.48, 8.29) controlPoint2: NSMakePoint(10.06, 4.04)];
    [tabPath curveToPoint: NSMakePoint(26.54, 4.04) controlPoint1: NSMakePoint(20.44, 4.03) controlPoint2: NSMakePoint(21.9, 3.96)];
    [tabPath curveToPoint: NSMakePoint(32.52, 8.29) controlPoint1: NSMakePoint(31.17, 4.11) controlPoint2: NSMakePoint(32.52, 8.29)];
    [tabPath curveToPoint: NSMakePoint(32.52, 18.49) controlPoint1: NSMakePoint(32.52, 8.29) controlPoint2: NSMakePoint(32.52, 15.01)];
    [tabPath curveToPoint: NSMakePoint(42, 23.6) controlPoint1: NSMakePoint(32.52, 21.98) controlPoint2: NSMakePoint(42, 23.6)];
    [tabPath lineToPoint: NSMakePoint(42, 27)];
    [tabPath lineToPoint: NSMakePoint(0, 27)];
    [tabPath closePath];
    [strokeColor setFill];
    [tabPath fill];
    [strokeColor setStroke];
    [tabPath setLineWidth: 1];
    [tabPath stroke];
    

    //// Color Declarations
    strokeColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];

    //// arrow Drawing
    NSBezierPath* arrowPath = [NSBezierPath bezierPath];
    [arrowPath moveToPoint: NSMakePoint(14.12, 8.5)];
    [arrowPath lineToPoint: NSMakePoint(17.28, 8.5)];
    [arrowPath lineToPoint: NSMakePoint(17.28, 14.9)];
    [arrowPath lineToPoint: NSMakePoint(14.12, 14.9)];
    [arrowPath lineToPoint: NSMakePoint(14.12, 8.5)];
    [arrowPath closePath];
    [arrowPath moveToPoint: NSMakePoint(15.5, 18.5)];
    [arrowPath lineToPoint: NSMakePoint(19.09, 14.9)];
    [arrowPath lineToPoint: NSMakePoint(11.91, 14.9)];
    [arrowPath lineToPoint: NSMakePoint(15.5, 18.5)];
    [arrowPath closePath];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy: 5.0 yBy: 1];
    [arrowPath transformUsingAffineTransform: transform];
    [strokeColor set];
    [arrowPath fill];
    [arrowPath setLineWidth: 1];
    [arrowPath stroke];

    if (_isHovered){
        [[NSColor alternateSelectedControlColor] set];
        [arrowPath fill];
        [arrowPath stroke];
    }
    
    if (_working){
        CGFloat progressSize = _progress;
        if (progressSize <= 0) {
            progressSize = 0.01;
        }

        //// Color Declarations
        NSColor* gradientColor = [NSColor colorWithCalibratedRed: 0 green: 0.663 blue: 0 alpha: 1];
        NSColor* gradientColor2 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];

        [gradientColor set];
        [arrowPath stroke];

        //// Gradient Declarations
        NSGradient* gradient = [[NSGradient alloc] initWithColorsAndLocations:
                                gradientColor, progressSize,
                                gradientColor, progressSize,
                                gradientColor2, MIN(progressSize + 0.01, 1.0),
                                gradientColor2, 1.0, nil];
        [gradient drawInBezierPath:arrowPath angle:90];
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
    if ([NSUserNotification class] && [NSUserNotificationCenter class]){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Copied to clipboard.";
        notification.informativeText = [(AppDelegate *)[[NSApplication sharedApplication] delegate] getLastUploadURL];
        notification.hasActionButton = NO;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
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

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    if(NSPointInRect([sender draggingLocation],self.frame)){
        //The file was actually dropped on the view so call the performDrag manually
        [self performDragOperation:sender];
    }
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
        [(AppDelegate *)[[NSApplication sharedApplication] delegate] startUpload:files deleteAfterUploading:NO];
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
