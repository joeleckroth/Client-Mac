#import <Cocoa/Cocoa.h>
#import "Finder.h"
#import "NSBezierPath+StrokeExtensions.h"

@interface StatusItemView : NSView <NSMenuDelegate> {
@private
    NSImage *_image;
    NSImage *_alternateImage;
    NSStatusItem *_statusItem;
    NSMenu *_menu;
    
    BOOL _isHighlighted;
    BOOL _isHovered;
    SEL _action;
    id _target;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, retain, readonly) NSStatusItem *statusItem;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImage *alternateImage;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL action;
@property (nonatomic, retain) id target;

@property (assign) float progress;
@property (assign) BOOL working;

@end
