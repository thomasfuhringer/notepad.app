/*
    Notepad.app
    a simple text editor featuring tabs
    all hand coded w/o NIB file    
    2010 by Thomas Führinger (gmail ID: thomasfuhringer)
 */

#ifndef _AppController_H_
#define _AppController_H_

#include <Foundation/NSObject.h>
#include <AppKit/AppKit.h>

@interface AppController : NSObject
{
    NSWindow *window;
    NSTabView *tabView;
    NSFont *font;
    NSWindow *prefsWindow;
}

- (void) applicationWillFinishLaunching:(NSNotification *) not;
- (void) applicationDidFinishLaunching:(NSNotification *) not;
- (void) openFile;
- (void) saveFile;
- (void) editPreferences;
- (NSFont *) font;
- (void) setFont: (NSFont *) newFont;
- (BOOL) windowShouldClose:(id) sender;
- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication *) app;

@end

#endif /* _AppController_H_ */

