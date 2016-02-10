# How to sort GitHub notifications in Gmail

Too many GitHub notifications in Gmail? This post gives an example of how to use
[Google app script](https://developers.google.com/apps-script/) to automatically
add labels like "Direct mention" and "Participating" to threads you care about.

## The script

My script builds upon Lyzi Diamond's post ["Manage GitHub notification messages
in Gmail with Google Apps
Scripts"](http://lyzidiamond.com/posts/github-notifications-google-script/).

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

## Changes

**Exit early when there are no threads to process**

This fixes timeout and resource exhaustion errors. Google has limits on how much
resources a script can take per run.

**Apply label by priority**

Rather than matching every GitHub header, this script applies the most important
label to a thread. I check my messages in this order:

* Direct Mention
* Partcipating
* Team mention
* Notification

This script assumes "Direct Mention", "Participating", "Team mention", and
"Notification" labels exist. [Labels can be created
programmatically](https://developers.google.com/apps-script/reference/gmail/gmail-app#createLabel(String)),
but I decided it was not worthwhile for such a simple script.

**Process newest messages first**

By processing newest messages first, threads will always have the highest
priority label applied. This is also good for performance because the script
stops processing a thread as soon as we label one of it's messages.

**Archive notification emails only**

Other GitHub emails should still pass through.
