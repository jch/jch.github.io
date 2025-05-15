# Customizing Turbo lifecycle events: iOS swipe view transitions

View transitions became available in Safari 18. Turbo had support for this, and the default experience is great in other browsers. There's a small hiccup that the default iOS and Safari browser back/forward swipe navigation animations cannot be disabled, leading to a double animation:

![](/images/view-transition-double.gif)

The intuitive turbo lifecycle callback to fix this would be to customize `turbo:before-render`. However, that's too late in the lifecycle. Instead, the fix was to conditionally disable view transitions on swipe gesture navigation by removing the view-transition meta tag in `turbo:before-cache`. Source and demo up at https://jch.github.io/turbo-cancel-view-transition/
Safari has the least friendly progressive web app experience, but I'm using it for my personal project. Hope this helps you in yours.