# Modular Cocoa Interfaces

While iOS projects have the advantage of multiple NIB files, this is
not the default for development on OSX. When working on a Mac or iOS
project with more than one person, you quickly learn that attempting
to merge conflicted Interface Builder files or XCode project files can
only result in tears. But just because you can't work on the same NIB
doesn't mean that the productivity of the entire team should be
blocked by the one person editing MainMenu.xib. Cocoa allows you to
chop your UI into separate NIBs and control them with multiple
NSWindowControllers. Once you separate out different windows from
MainMenu, you're much less likely to conflict with your team. As an
added benefit, your UI will feel snappier because NIB loading will be
delayed until it's actually needed. I'll demonstrate this technique by
separating the Preferences window from the main window, a common and
easy case for refactoring.

## Code

For starters, let's create a new NSWindowController subclass for
driving our Preferences window.  We'll name it PreferencesController.

The header:

    #import <Cocoa/Cocoa.h>
    @interface PreferencesController : NSWindowController {
    }
    @end

The implementation:

    #import "PreferencesController.h"
    @implementation PreferencesController

    - (id) init {
      if(self = [super initWithWindowNibName:@"Preferences"]) {
      }
      return self;
    }

The only difference from a generic NSWindowController is the custom
constructor. This controller will try to load a NIB named
"Preferences.xib" when it's -showWindow: method is called. In the
Xcode sidebar, right click Resources, Add File, User Interface, and
choose "Window XIB".  Name this xib "Preferences.xib".

## Interface Builder

Next comes the error-prone step.  If you don't add all the right
connections in Interface Builder, then your new window will act
erratically.  It might not show up, it might not be in focus, it might
not close, or it might explode your Mac (unlikely, but not
impossible).  First, add an NSObject to your Document and change the
'Class' to 'PreferencesController'

<div class="thumbnail"><a href="https://skitch.com/jollyjerry/rg3ir/preferences-controller-identity-2"><img src="https://img.skitch.com/20101227-nmxnxp4na7p8mtgj15ea7ifhmm.preview.jpg" alt="Preferences Controller Identity-2" /></a></div>

<br>

To test that our NIB is loading properly, let's connect the
'Preferences' menu item to the showWindow: action.

<div class="thumbnail"><a href="https://skitch.com/jollyjerry/rg3ix/menu-item-connections"><img src="https://img.skitch.com/20101227-ecupcfjkk6s6nsxiwrpe6deyjy.preview.jpg" alt="Menu Item Connections" /></a></div>

<br>

We're almost there, but if you run the app now, you'll notice that the
Preferences window doesn't focus properly. While our "MainMenu.xib"
has a reference to PreferencesController, we forgot to let
Preferences.xib know that its owner is of type PreferencesController.
Open "Preferences.xib", and change "File's Owner" to
PreferencesController, and also set its "window" connection to point
to the window.

<div class="thumbnail"><a href="https://skitch.com/jollyjerry/rg3ii/preferences-controller-connections"><img src="https://img.skitch.com/20101227-qdrtdix38yxr41bp78583wjifm.preview.jpg" alt="Preferences Controller Connections" /></a></div>

<br>

If you Build and Run the project now, you should be able to open the
Preferences window from the menu and have the 2nd Preferences window
loaded. Open and close the Preference window a few times for good
measure too.  If something is acting funny, the most likely culprit is
a missing connection for "File's Owner" in "MainMenu.xib" or a missing
connection for the menu. Go over the steps again and recheck your
class identities and connections (cmd-5) in the inspector to make sure
everything is wired correctly.

## What's Next?

From here, whenever you need to make changes to the Preferences
window, no changes need to be introduced to "MainMenu.xib". Controller
actions can be specified on PreferencesController, and Interface
Builder can access those actions by making connections to "File's
Owner". For a demo, check out [this account preferences
demo](https://github.com/jch/cocoa-separate-nib-preferences).
Hopefully, you can use this process in your project to cut down on
nasty merges.

## Resources

* [Account Preferences Example](https://github.com/jch/cocoa-separate-nib-preferences) - a more fleshed out version of this article.
* [Window Programming Guide](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/WinPanel/WinPanel.html) - best starting place for anything related to windows.
* [NSWindowController description](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/WinPanel/Concepts/UsingWindowController.html)
* [NSWindowController Class Reference](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/Classes/NSWindowController_Class/Reference/Reference.html) - as always, Apple's docs are a good place to start
* [Introduction to Document-Based Applications Overview](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Documents/Documents.html#//apple_ref/doc/uid/10000006i) - looking at the Document architecture helps give you an understanding of how Window controllers and NIBs interact.
