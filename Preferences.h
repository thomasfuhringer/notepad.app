#ifndef _Preferences_H_
#define _Preferences_H_

#include <Foundation/NSObject.h>
#include <AppKit/AppKit.h>

@interface PreferencesDialog : NSWindow
{
    NSTextField *labelFont;
    NSComboBox *fontComboBox;
    NSButton *okButton;
    NSButton *cancelButton;
}

- (id) init;
- (void) accept: (id) sender;

@end

#endif /* _Preferences_H_ */
