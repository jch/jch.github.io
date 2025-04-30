# Dark mode and RSS

Bit of clean up for the blog. I've cleaned up the CSS to use browser defaults
for the most part. Instead of using hex colors, I used [named colors](https://developer.mozilla.org/en-US/docs/Web/CSS/named-color)
and chose colors that work well on a light and dark background. For dark mode,
I used `black` for OLED screens instead of a dark gray.

```css
body {
  max-width: 80ch;
  padding: 1em;
  margin: auto;
}

.highlight pre {
  border-left: 2px solid palegoldenrod;
  padding-inline-start: 0.75em;
}

.pl-c {color: darkgray;}
.pl-c1, .pl-s .pl-v {color: deepskyblue;}
.pl-e, .pl-en {color: mediumslateblue;}
.pl-s .pl-s1, .pl-smi {color: gray;}
.pl-ent  {color: mediumseagreen;}
.pl-k {color: coral;}
.pl-pds, .pl-s, .pl-s .pl-pse .pl-s1, .pl-sr, .pl-sr .pl-cce, .pl-sr .pl-sra, .pl-sr .pl-sre {color: deepskyblue;}
.pl-v {color: salmon;}
.pl-id {color: coral;}
.pl-ii {background-color: coral; color: black;}
.pl-sr .pl-cce {color: mediumseagreen; font-weight: bold;}
.pl-ml {color: goldenrod;}
.pl-mh, .pl-mh .pl-en, .pl-ms {color: deepskyblue; font-weight: bold;}
.pl-mq {color: deepskyblue;}
.pl-mi {color: gray; font-style: italic;}
.pl-mb {color: gray; font-weight: bold;}
.pl-md {background-color: mistyrose; color: coral;}
.pl-mi1 {background-color: honeydew; color: mediumseagreen;}
.pl-mdr {color: mediumslateblue; font-weight: bold;}
.pl-mo {color: deepskyblue;}

@media (prefers-color-scheme: dark) {
  body {
    background-color: black;
    color: snow;
  }

  a {
    color: aqua;
  }

  a:visited {
    color: orchid;
  }

  a:hover, a:focus {
    color: lightsalmon;
  }

  a:active {
    color: lightcoral;
  }
}
```

I added a new `bin/publish_rss` for feed readers and validated with W3C.

## Update 2025-04-12

From https://inclusive-components.design/a-theme-switcher/

```css
:root {
   background-color: #fefefe;
   filter: invert(100%);
}

* {
   background-color: inherit;
}

img:not([src*=".svg"]), video {
   filter: invert(100%);
}
```

## Update 2025-04-30

```css
@media (prefers-color-scheme: dark) {
  body {
    background-color: black;
    color: snow;
  }

  a, a:visited { color: #0df; }
}
```
