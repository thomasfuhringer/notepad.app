#include <AppKit/AppKit.h>
#include "Preferences.h"

@implementation PreferencesDialog
- (id) init
{
    [super initWithContentRect: NSMakeRect(300, 300, 400, 250)
                     styleMask: (NSTitledWindowMask | NSClosableWindowMask)
                       backing: NSBackingStoreBuffered
                         defer: YES];
                                            
    [self setTitle: @"Preferences"];
    
    labelFont = [[NSTextField alloc] initWithFrame: NSMakeRect(40, 180, 40, 20)];
    [labelFont setSelectable: NO];
    [labelFont setBezeled: NO];
    [labelFont setDrawsBackground: NO];
    [labelFont setStringValue: @"Font"];
    [[self contentView] addSubview: labelFont];

    fontComboBox = [[NSComboBox alloc] initWithFrame: NSMakeRect(80, 180, 280, 20)];
    [fontComboBox addItemsWithObjectValues: [[NSFontManager sharedFontManager] availableFonts]];
    [fontComboBox setStringValue: [[[NSApp delegate] font] fontName]];
    [[self contentView] addSubview: fontComboBox];
    
    okButton = [[NSButton alloc] initWithFrame: NSMakeRect(300, 30, 60, 24)];
    [okButton setStringValue: @"OK"];
    [okButton setAction: @selector(accept:)];
    [okButton setTarget: self];
    [[self contentView] addSubview: okButton];
    
    cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(230, 30, 60, 24)];
    [cancelButton setStringValue: @"Cancel"];
    [cancelButton setAction: @selector(close)];
    [cancelButton setTarget: self];
    [[self contentView] addSubview: cancelButton];

    return self;
}

- (void) accept: (id) sender
{
    [[NSApp delegate] setFont: [NSFont fontWithName: [fontComboBox stringValue] size: 0]];
    [self close];
}
    
- (void) dealloc
{
    [labelFont release];
    [fontComboBox release];
    [okButton release];
    [cancelButton release];
    [super dealloc];
}
@end
