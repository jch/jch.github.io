# How to sort GitHub notifications in Gmail

[Google app script](https://developers.google.com/apps-script/) can filter
GitHub notifications in Gmail. My script is based on Lyzi Diamond's post
["Manage GitHub notification messages in Gmail with Google Apps
Scripts"](http://lyzidiamond.com/posts/github-notifications-google-script/), but
with the following changes:

* Exits early when there are no threads to process. This prevents timeouts.
* Processes newest messages first. Again, prevents timeouts and errors.
* Applies label by priority (Direct Mention > Participating > Team mention > Notification).
* Only archive notification emails, not all emails from github.com.

This script assumes "Direct Mention", "Participating", "Team mention", and
"Notification" labels exist. [Labels can be created
programmatically][createLabel], but I decided it was not worthwhile for such a
simple script.

The full API reference for Gmail is available at
https://developers.google.com/apps-script/reference/gmail/.

```javascript
// Main function
function processInbox() {
  var unreadThreadCount = GmailApp.getInboxUnreadCount();
  if (unreadThreadCount == 0) { return null; }

  var threads = GmailApp.getInboxThreads(0, unreadThreadCount);
  for (var i = 0; i < threads.length; i++) {
    var thread = threads[i];
    var messages = thread.getMessages();

    if ((messages[0].getFrom()).indexOf("notifications@github.com") > -1) {
      thread.moveToArchive();

      // Iterate through newest messages, returning a GmailThread if a label was added to the thread.
      // Only one label will be added, and they are listed in priority below.
      var start = Math.max(0, messages.length - 1);
      var label;
      for (var j = start; j > -1; j--) {
        var message = messages[j];
        var body = message.getRawContent();
        if (body.indexOf("X-GitHub-Reason: mention") > -1) {
          return thread.addLabel(GmailApp.getUserLabelByName("Direct mention"));
        } else if ((body.indexOf("X-GitHub-Reason: author") > -1) || (body.indexOf("X-GitHub-Reason: comment") > -1)) {
          return thread.addLabel(GmailApp.getUserLabelByName("Participating"));
        } else if (body.indexOf("X-GitHub-Reason: team_mention") > -1) {
          return thread.addLabel(GmailApp.getUserLabelByName("Team mention"));
        } else {
          return thread.addLabel(GmailApp.getUserLabelByName("Notification"));
        }
      }
    }
  }
}
```

[createLabel]: https://developers.google.com/apps-script/reference/gmail/gmail-app#createLabel(String)
