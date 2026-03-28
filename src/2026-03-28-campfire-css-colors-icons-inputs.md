# Campfire lessons: colors, icons, and inputs

Gather around folks, here's what I learned and applied to [jch.app](https://jch.app) from 37signal's "Modern CSS Patterns in Campfire", and the source code from Campfire and Fizzy. 

I test drove these techniques on the Holdings page. I needed these changes to be incremental and opt-in to avoid breaking other pages.

## Colors

Up until I shipped dark mode, I used tailwind's color utilities. Tailwind does come with a `dark:`, but it was hard to reason about and I found myself repeating a lot of utilties with slight variations (border-pink-300, bg-pink-300) and needing to find-and-replace several things to try different colors.

```css
/* before */
input:focus {
  @apply border-pink-300;      /* light mode */
  @apply dark:border-pink-900; /* dark mode */
}
```

This pushed me to add an abstraction for semantic colors on top of the primitive color definitions.

```css
/* after */
:root {
  /* semantic colors */
  --color-highlight: oklch(var(--lch-pink));
  
  /* primitive colors */
  --lch-pink: ...; /* light mode default */
  @media (prefers-color-scheme: dark) {
    --lch-pink: ...;  /* redefine it to fit dark */
  }
}

input:focus {
  border: 1px solid var(--color-highlight);
}
```

Instead of describing a border color as light pink in light mode, and dark pink in dark mode, it's styled with a single semantic `--color-highlight` and allows `--lch-pink` to be redefined by dark mode.

Not every color needed a semantic name. The pattern I learned was to define raw color primitives as `--lch-[color]-[lighter|light|dark|darker]` and optionally add semantic named colors like `--color-[semantic-name]`. When applying colors in dark mode, redefine the raw `--lch-*` color vars while relying on semantic `--color-*` vars for styling.

One aha moment was realizing that the variables are resolved at render. Notice how `--color-highlight: oklch(var(--lch-pink))` uses `--lch-pink` before it is defined. This works because when a `input:focus` selector matches an element, `--lch-pink` will resolve to a value based on light or dark mode. Trust that the variables will have a value defined at some point, whether it's a app wide value in `:root`, as a fallback, in a component or variant, or inline at the html itself. This also explains why `application.html.erb` can load all the stylesheets and not worry about the load order.

```erb
<%= stylesheet_link_tag :all %>
```

## Icons

I started with inline svg icons because this allowed me to easily change their colors by defining their stroke color as `currentColor`.

```html
/* easy to style svg icon colors */
<div style="color: red">
  <!-- icon inherits color -->
  <svg stroke="currentColor"></svg>
</div>
```

But this stops working if the svg is in an external file

```css
/* currentColor ignored */
.icon--search {
  background-image: url("data:..."); /* inlined in css */
  background-image: url("plus.svg"); /* or external file */
}
```

The 37signals approach uses the svg as an `image-mask` over a background. The strokes of the icon form the visible parts of the mask, and the color from the image show through the mask.

```css
.icon {
  background-color: currentColor;
  mask-image: var(--svg);
}

.icon--search {
  --svg: url("search.svg");
}
```

Aside: propshaft translates `url("search.svg")` to the digested file. Neat. Having cached digested icon files means sending fewer bytes inline with the response.

## Inputs

When icons were background images, I used relative positioning and padding to add a magnifying glass icon to a search input:

```css
input[type=search] {
  --inline-space: 1ch;

  background-image: url("search.svg");
  background-position: center left var(--inline-space);
  background-repeat: no-repeat;
  
  /* space + icon + space before input content */
  padding-inline-start: calc(--icon-size + var(--inline-space) * 2);
}
```

I liked how this kept the html semantic without a wrapper element. But this meant a fixed icon for both light and dark mode, and prevented using css variables for customization. My first thought was using a `::before` pseudo element to add the background image, but `<input>`s don't allow pseudo elements. So I experimented with a wrapper:

```html
<style>
  .icon-wrapper {
    position: relative;
    
    & .icon {
      position: absolute;
      
      /* center vertically */
      top: 50%;
      transform: translate-y(-50%);
    }
    
    & input {
      padding-inline-start: calc(var(--icon-size) + 2ch);
    }
  }
</style>
<div class="icon-wrapper">
  <span class="icon icon--search"></span>
  <input type="search" />
</div>
```

This worked, but I didn't like how the input had to calculate the correct padding to know where it started. What I really wanted was to use flexbox and have the following:

```
+---+--------+
| o | xxxxxx |
+---+--------+
o = icon
x = input text
- = border
```

Then I could use gap for spacing and flexbox for alignment. I thought I could get clever with an input background image and a mask:

```css
input[type=search] {
  background-image: linear-gradient(blue, red);
  background-position: left center;
  background-size: 1em 1em;
  
  mask-image:
    url("search.svg"),             /* mask 1: icon color */
    linear-gradient(black, black); /* mask 2: input text */
}
```

This kinda worked, but ends up masking out the border on the icon side:

```
    +--------+
  o | xxxxxx |
    +--------+
o = icon
x = input text
- = border
```

I messed with the `mask-*` properties, and while `mask-origin` sounded promising, it still ended up masking out the border. With border widths defined in variables and additional masks, this felt doable, but I stopped because it felt complex and brittle.

Studying campfire's `inputs.css`, their approach is to style the wrapper like an input, and hide an input's styling when it's within a wrapper. Input styling is defined by `.input` and a wrapper acting as an input is an `.input--actor`.

```html
<div class="input input--actor" style="display: flex; gap: 1ch">
  <span class="icon icon--search"></span>
  <input type="search" class="input" />
</div>
```

The clever bits here were 

1. adding input border, outlines, focus states on the wrapper with `.input` 2. using a child selector to clear the actual `<input>` styling with css vars 

```css
/* inputs.css */
.input {
  border: 1px solid var(--input-border-color, gray);
}

.input--actor {
  & .input {
    /* hide when inside a wrapper acting as an input */
    --input-border-color: transparent;
  }
}
```

Campfire wraps all of it's inputs with these classes, assuming input styling has been reset in `base.css`. But since I wanted to make incremental changes without breaking inputs on other pages, I didn't pull in their `base.css`. Even if I had, the base reset uses a `:where` selector with zero specificity that wouldn't override my `input[type=search]` styling. I was impressed that campfire's stylesheets are self-contained and could be added to my project without overriding my styles.

## Take aways

- Think decoratively. What variables and fallbacks do I need?
- Undo-ing styles is a smell that suggests a missing css variable.
- Zero specificity `:where` for reset and base styling
- Define and redefine colors based on light / dark mode like `--lch-blue`
- Define named semantic colors like `--color-link` that depend on varying lch variables

## Reference

- [Modern CSS patterns in Campfire](https://dev.37signals.com/modern-css-patterns-and-techniques-in-campfire/)
- [Campfire](https://github.com/basecamp/once-campfire)
- [Fizzy](https://github.com/basecamp/fizzy)
- [Propshaft #7: Add digest to valid urls in assets](https://github.com/rails/propshaft/pull/7)
- [MDN: mask](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/mask)
