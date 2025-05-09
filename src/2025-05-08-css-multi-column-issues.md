# CSS Fragmentation issues with multi column

After reading [When and How to Use CSS Multi-Column Layout](https://www.smashingmagazine.com/2019/01/css-multiple-column-layout-multicol/), I tried to use it for a masonry layout for the [jch.app](https://jch.app) dashboard.

While there is a `grid-template-rows: masonry`, it is not widely available in 2025. I wanted a single column of items on mobile, and 300px wide columns added as the viewport allowed. Items would have auto width and height, and allow the columns to determine width:

```css
#container {
  columns: 300px;
  gap: 1em; /* inline axis gutter */
}

.item {
  box-shadow: mintcream 3px 3px;
  margin-bottom: 1em; /* block axis gutter */
}
```

```html
<div id="container">
  <div class="item">First</div>
  <div class="item">Second, with more stuff</div>
  <div class="item">Third, and a whole lotta more so it wraps when viewport is small</div>
  <div class="items">Fourth, because why not</div>
</div>
```

This worked great! Kinda. But then I noticed an extra line and gap would appear in the new column when the viewport widened. It didn't show up in the web inspector, but some fiddling narrowed down `box-shadow` to cause the unwanted line, and `margin-bottom` to cause the excess gap. This only occured on Safari (mobile and desktop). I found several related issues on bugzilla, but the ones with the most context are:

* [Bug 14137: box-shadow on element inside multi-column doesn't draw outside column boundary](https://bugs.webkit.org/show_bug.cgi?id=14137#c17)
* [Bug 104944: CSS Fragmentation Implement correct margin truncation at breaks](https://bugs.webkit.org/show_bug.cgi?id=104944#c9)

I've linked to my comments with the reproduction HTML and CSS.

I was open to removing the box-shadow or changing it to an inset shadow, but the [CSS fragmentation](https://www.smashingmagazine.com/2019/02/css-fragmentation/) bug affecting margins is a dealbreaker because it causes the boxes to not line up at the top for multiple columns. I tried using [margin collapsing](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_box_model/Mastering_margin_collapsing) by setting `margin-block: 2.5em`, which collapsed fine within the same column, but didn't work on the first item of the new column. I also tried to wrap my items and use padding for gutters rather than margins, but padding would also push into the top of new columns (womp womp).

Multi-column is still useful for prose, and content that doesn't require alignment, but unfortunately does not work in Safari for a masonry layout of cards. Long term, using the masonry grid layout is the right way to go, but I was hoping this would provide a simple CSS-only fallback.
