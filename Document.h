#include <AppKit/AppKit.h>

@interface Document : NSObject
{
    NSTabView *tabView;
    NSTabViewItem *tabViewItem;
    NSTextView *textView;
    NSString *fileName;
    BOOL edited;
}

- (Document *) initWithView: (NSTabView *) view;
- (void) loadFromFile: (NSString *) file;
- (BOOL) save;
- (BOOL) saveAs: (NSString *) file;
- (BOOL) close;
- (BOOL) isEdited;
- (NSFont *) font;
- (void) setFont: (NSFont *) newFont;
- (NSString *) fileName;

@end
