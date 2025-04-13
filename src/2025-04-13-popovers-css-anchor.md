# Popovers and Anchor Positioning

Popover made it into baseline this year. I wanted to use it to replace the dialog
modal sheet I was using because it comes with soft dismiss built-in. Initial testing
was good, but iOS Safari hangs if there is an input within the popover. The fix is slated
for 18.4 in April 2025, so I will stay with dialog until some time after that.

- popover: https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/popover
- dialog: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog
- https://stackoverflow.com/questions/79501074/focusing-input-blocks-page-on-safari-when-part-of-element-with-popover-api

Anchor positioning is in technical preview for Safari and available for 71% of browsers.
I had planned to make the modal sheet stick to the bottom on small viewports (easy without anchors),
and near the trigger in larger viewports (anchors necessary because it's in the top layer).
But after testing on the simulator and devices, I found that iOS Safari has a
not-quite-keyboard sized element on the bottom of the HTML element
that I cannot prevent scrolling when an input is focused.

I've seen this on several other sites, and it's a nitpick but annoying enough to me
I would make the modal *feel* like the web rather than try and emulate a native
modal sheet.

I'd like to revisit anchor positioning for some of the filter menus.

- https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_anchor_positioning
- https://developer.mozilla.org/en-US/docs/Glossary/Top_layer
- https://caniuse.com/css-anchor-positioning