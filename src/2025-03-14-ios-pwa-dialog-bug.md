# iOS Progressive Web App Dialog bug

This was a fun one. I'm adding a modal dialog to quickly
add a number of stock shares.

On iOS mobile safari 18.3.1, the form in the modal freezes up
after the date picker makes a selection. It's as if the modal
itself becomes [inert](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/inert).

My hack workaround is to scroll the page by a pixel when the
input loses focus `onblur`. This seems to unfreeze the page. Note this hack is only needed if a page is saved to the home screen as a PWA. It works fine from Safari mobile.

```html
<dialog>
  <form>
    <label>
      Purchase date
      <input type="date" onblur="window.scrollBy(0, 1);">
    </label>
    <label>
      Shares
      <input type="number">
    </label>
    <input type="submit">
  </form>
</dialog>
```