# Dangerous Scaffolding #

I did something bad today.  It wasn't bad enough to destroy working
customer instances, but it was enough to make all the dev team all up
in a huff.  The worst part of the whole experience was a) I didn't
remember I was the one who nuked it, and b) it got nuked because of
some crufty scaffolding and default behaviours.

Backtrack a few days and imagine this scenario: I was working on an
open ticket about permissions.  I needed a user with a specific role
to test with, so I looked up that user.  I didn't know the user's
password, so in my impatience, I go to my awesome bar and type in
'/user/edit' by hand.  An innoculous page renders, and I see the
change password fields on the bottom of the page.  I type in a bogus
password, and hit enter.

All that seemed straight forward enough until I realized that the
default form action under the change password section was "Delete
User".  Not even this raised any warning flags in my mind.  It wasn't
until a few days later when all kinds of crazy @#$! related to missing
users started happening that I took notice.  Can you guess what
happened?

The first thing that went wrong was me hijacking the URL by hand
instead of going through what the UI meant for me to do.  The app does
all it's edits and changes through users/show instead of users/edit.
What users/edit renders instead is a well hidden scaffolded view from
many moons ago.  This form calls users/destroy.  But wait!  The riddle
is far from over.  Not only did the user I was working on get nuked,
but several other users also mysteriously disappeared.  This came
about as a result of the User model mixing in acts_as_tree.  Acts as
tree apparently has an undocumented assumption that it should destroy
it's children when the root is destroyed.  At least I wasn't the
[first person to be burned](http://dev.rubyonrails.org/ticket/1924) by
this.
