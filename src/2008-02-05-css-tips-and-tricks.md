# CSS Tips and Tricks #

These aren't organized in any way for now.  Maybe when I collect
enough of them, I'll create a cookbook of some kind.

### Centering within a Block Element ###

<div id="outer" style="width: 350px; background-color: pink;">
  <div id="centered" style="border: 1px solid black; width: 150px; margin: 0px auto; text-align: center">
      <p>Le Awesome!</p>
      <p>Poo poo!</p>
  </div>
</div>


### Clearing Block Elements ###

The clear attribute of block elements specify whether anything can
occur to the *left* or *right* or *both* (either side) of a block
element.  For example, if a div has 'clear: left' set on it, then no
element will be allowed to be left of it.  If there is, then the
cleared element will be pushed down to the next line.

### Spacing ###

Spacing is really important and can be hard to remember at first, but
it's really intuitive after you learn it:

      Margin
      +-----Border---------------------------------------+
      |           Padding                                |
      |                                                  |
      |     Content                                      |
      |                                                  |
      |                                                  |
      |                                                  |
      |                                                  |
      |                                                  |
      +--------------------------------------------------+

* [CSS to do anything](http://www.noupe.com/css/using-css-to-do-anything-50-creative-examples-and-tutorials.html)
* [Sticky Bottom Footer](http://ryanfait.com/resources/footer-stick-to-bottom-of-page/)