#include <AppKit/AppKit.h>
#include "Document.h"

@implementation Document

- (Document *) initWithView: (NSTabView *) view
{
    tabView = view;
    
    tabViewItem = [[NSTabViewItem alloc] initWithIdentifier: self];
    [tabViewItem setLabel: @"New File"];

    NSScrollView *scrollView = [[NSScrollView alloc] init];
    [scrollView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable ];
    [scrollView setHasHorizontalScroller: NO];
    [scrollView setHasVerticalScroller: YES];
    [tabViewItem setView: scrollView];
    
    textView = [[NSTextView alloc] initWithFrame: [scrollView frame]];
    [textView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
    [textView setVerticallyResizable: YES];
    [textView setHorizontallyResizable: YES];
    [[textView textContainer] setWidthTracksTextView: NO];
    [textView setHorizontallyResizable: NO];
    [textView setVerticallyResizable: YES];

    [textView setFont: [[NSApp delegate] font]];
    [textView setDelegate: self];
    [scrollView setDocumentView: textView];
    
    [tabView addTabViewItem: tabViewItem];
    [tabViewItem setInitialFirstResponder: textView];
    [tabView selectLastTabViewItem: self];
    
    edited = NO;
    
    return self;
}

- (void) loadFromFile: (NSString *) file
{
    NSString *aString = [NSString stringWithContentsOfFile: file];
    [textView setString: aString];
    fileName = file;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cleanFileName = [fileManager displayNameAtPath: fileName];
    [tabViewItem setLabel: cleanFileName];
}

- (BOOL) save
{
    if ([[textView string] writeToFile: fileName atomically: YES])
    {
        edited = NO;
        return YES;
    }
    else
        return NO;
}

- (BOOL) saveAs: (NSString *) file;
{
    if ([[textView string] writeToFile: file atomically: YES])
    {
        fileName = file;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cleanFileName = [fileManager displayNameAtPath: fileName];
        [tabViewItem setLabel: cleanFileName];
        edited = NO;
        return YES;
    }
    else
        return NO;
}

- (BOOL) close
{
    if (edited)
    {
        int r = NSRunInformationalAlertPanel([NSString stringWithFormat: @"The document '%@' has changed!", (NSString *)[tabViewItem label]], @"Save changes?", @"Save", @"Cancel", @"Don't Save");
        switch (r)
        {
            case NSAlertAlternateReturn:
                return NO;
                break;
            case NSAlertDefaultReturn:
                [self save];
                break;
        }
    }
    [tabView removeTabViewItem: tabViewItem];
    return YES;
}

- (BOOL) isEdited
{
    return edited;
}

- (NSString *) fileName
{
    return fileName;
}

- (NSFont *) font
{
    return [textView font];
}

- (void) setFont: (NSFont *) newFont
{
    [textView setFont: newFont];
}

- (void) dealloc
{
    [textView release];
    [tabViewItem release];
    [fileName release];
    [super dealloc];
}

// delegate for TextView
 - (void) textDidChange: (NSNotification*) notification;
{
    edited = YES;
}

@end
