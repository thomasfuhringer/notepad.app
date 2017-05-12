#include <AppKit/AppKit.h>
#include "AppController.h"
#include "Document.h"
#include "Preferences.h"

@implementation AppController
- (void) applicationWillFinishLaunching: (NSNotification *) not
{
   /* Create Menu */
   NSMenu *mainMenu;
   NSMenu *fileMenu;
   NSMenu *editMenu;

   mainMenu = [NSMenu new];
   [mainMenu addItemWithTitle: @"File"
                   action: NULL
            keyEquivalent: @"f"];

   [mainMenu addItemWithTitle: @"Edit"
                   action: NULL
            keyEquivalent: @"e"];

   [mainMenu addItemWithTitle: @"Info..."
                   action: @selector(orderFrontStandardInfoPanel:)
            keyEquivalent: @""];            
   [mainMenu addItemWithTitle: @"Hide"
                   action: @selector(hide:)
            keyEquivalent: @"h"];
   [mainMenu addItemWithTitle: @"Quit"
                   action: @selector(terminate:)
            keyEquivalent: @"q"];


   fileMenu = [NSMenu new];
   [fileMenu addItemWithTitle: @"New"
                   action: @selector(newFile)
            keyEquivalent: @"n"];
   [fileMenu addItemWithTitle: @"Open..."
                   action: @selector(openFile)
            keyEquivalent: @"o"];
   [fileMenu addItemWithTitle: @"Save"
                   action: @selector(saveFile)
            keyEquivalent: @"s"];
   [fileMenu addItemWithTitle: @"Save As..."
                   action: @selector(saveAsFile)
            keyEquivalent: @""];
    [fileMenu addItemWithTitle: @"Close"
                   action: @selector(closeFile)
            keyEquivalent: @"w"];

    [mainMenu setSubmenu: fileMenu
            forItem: [mainMenu itemWithTitle: @"File"]];
    [fileMenu release];
   

    editMenu = [NSMenu new];
    [editMenu addItemWithTitle: @"Preferences"
                   action: @selector(editPreferences)
            keyEquivalent: @"p"];
/*
    [editMenu addItemWithTitle: @"Font"
                   action: NULL
            keyEquivalent: @"f"];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSMenu *fontMenu = [fontManager fontMenu:YES];
    [editMenu setSubmenu: fontMenu forItem: [editMenu itemWithTitle: @"Font"]];
   */
    [mainMenu setSubmenu: editMenu
                 forItem: [mainMenu itemWithTitle: @"Edit"]];
    [editMenu release];

    [NSApp setMainMenu: mainMenu];
    [mainMenu release];


    /* Create Window */
    window = [[NSWindow alloc] initWithContentRect: NSMakeRect(300, 300, 600, 400)
                                        styleMask: (NSTitledWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask|NSClosableWindowMask)
                                          backing: NSBackingStoreBuffered
                                            defer: YES];
    [window setDelegate: self];
    [window setTitle: @"Notepad"];
    [window setFrameAutosaveName: @"NotepadMainWindow"];

    NSToolbar *mainToolbar = [[NSToolbar alloc] initWithIdentifier: @"Toolbar"];
    [mainToolbar setDelegate: self];
    [window setToolbar: mainToolbar];
    [window setShowsToolbarButton: YES];
    [mainToolbar release];
   
    tabView = [[NSTabView alloc] init];

    [window setContentView: tabView];

    NSData *fontData = [[NSUserDefaults standardUserDefaults] dataForKey: @"Font"];
    if (fontData != nil)
        font = (NSFont *)[NSUnarchiver unarchiveObjectWithData: fontData];
    
    [[Document  alloc] initWithView: tabView];

   //[[window contentView] addSubview: tabView];
   // [window makeFirstResponder:textView];
}

- (void) applicationDidFinishLaunching: (NSNotification *) not
{
   [window makeKeyAndOrderFront: self];
}

- (void) dealloc
{
    [tabView release];
    [[window toolbar] release];
    [window release];
    [super dealloc];
}

- (NSFont *) font
{
    return font;
}

- (void) setFont: (NSFont *) newFont
{
    font = newFont;
    NSArray *items = [tabView tabViewItems];
    unsigned int i;
    for (i = 0; i < [items count]; i++)
    {
        [[[items objectAtIndex: i] identifier] setFont: font];
    }

    NSData *fontData = [NSArchiver archivedDataWithRootObject: font];
    [[NSUserDefaults standardUserDefaults] setObject: fontData forKey: @"Font"];
}

- (void) newFile
{
    [[Document  alloc] initWithView: tabView];
}

- (void) openFile
{
    Document *document = [[tabView selectedTabViewItem] identifier];

    NSOpenPanel* openDlg = [NSOpenPanel openPanel];

    if ([openDlg runModalForDirectory: nil file: nil] == NSOKButton)
    {
        NSArray* files = [openDlg filenames];
        NSString* fileName = [files objectAtIndex: 0];

        if ([document fileName] || [document isEdited])
        {
            [self newFile];
            document = [[tabView selectedTabViewItem] identifier];
        }

        if ([tabView selectedTabViewItem])
        {
            [document loadFromFile: fileName];
        }
    }
}

- (void) saveFile
{
    Document *document = [[tabView selectedTabViewItem] identifier];
    if(![document save])
        NSRunInformationalAlertPanel(@"Error", @"File could not be saved!", @"OK", nil, nil);
}

- (void) saveAsFile
{
    Document *document = [[tabView selectedTabViewItem] identifier];
    NSSavePanel* saveDlg = [NSSavePanel savePanel];

    if ([saveDlg runModalForDirectory: nil file: nil] == NSOKButton)
    {
        if(![document saveAs: [saveDlg filename]])
            NSRunInformationalAlertPanel(@"Error", @"File could not be saved!", @"OK", nil, nil);
    }
}

- (void) closeFile
{
    Document *document = [[tabView selectedTabViewItem] identifier];
    [document close];
}

- (void) editPreferences;
{
    prefsWindow = [[PreferencesDialog alloc] init];   
    [prefsWindow center];
    [NSApp runModalForWindow: prefsWindow];    
    //[prefsWindow release];
}

- (BOOL)windowShouldClose: (id)sender
{    
    NSArray *items = [tabView tabViewItems];
    unsigned int i;
    BOOL allClosed = YES;
    for (i = 0; i < [items count]; i++)
    {
        if (![(Document *) [[items objectAtIndex: i] identifier] close])
            allClosed = NO;
    }

    //[items release];
    return allClosed;
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
    return YES;
}

- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication *)app
{
    return NSTerminateNow;
}

// Can't get this to work...
// Toolbar delegate
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) itemIdentifier
  willBeInsertedIntoToolbar: (BOOL) flag
{
    //NSLog(itemIdentifier);
    id item;
  
    if ([itemIdentifier isEqualToString: @"Save"])
    {
        item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [item setLabel: _(@"Save")];
        [item setPaletteLabel: _(@"Save Document")];
        [item setImage: [NSImage imageNamed: @"NSApplicationIcon"]];
        [item setTarget: self];
        [item setAction: @selector(saveFile:)];
    NSLog([[item image] name]);
    }
    else if ([itemIdentifier isEqualToString: @"Close"])
    {
        item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [item setLabel: _(@"Close")];
        [item setPaletteLabel: _(@"Close Document")];
        [item setImage: [NSImage imageNamed: @"NSApplicationIcon"]];
        [item setTarget: self];
        [item setAction: @selector(saveFile:)];
    }
    return [item autorelease];
}


- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar
{
  return [NSArray arrayWithObjects: @"Save",
		  @"Close",
							  NSToolbarSpaceItemIdentifier,
          //NSToolbarFlexibleSpaceItemIdentifier,
		  nil];
}


- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar
{
    //NSLog(@"defit");
  return [NSArray arrayWithObjects: @"Save",
		  @"Close",
							  NSToolbarSpaceItemIdentifier,
          //NSToolbarFlexibleSpaceItemIdentifier,
		  nil];
}
/*
- (BOOL) validateToolbarItem: (NSToolbarItem *) theItem
{
    return YES;
}
*/
@end


