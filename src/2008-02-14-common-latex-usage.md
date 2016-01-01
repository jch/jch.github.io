# Common Latex Usage #

Since high school, I've used word processors less and less.  I hate
how slow they load, I hate how annoying and proprietary the formats
are, I hate how ugly they end up printing and how hard it is to
customize my documents.  Enter Latex.

## Overview ##

Wikipedia defines [Latex](http://en.wikipedia.org/wiki/LaTeX) to be:

> LaTeX is a document markup language and document
> preparation system for the TeX typesetting program.

In practice, I like to think of it as a document processor plugin for
the editor of your choice.  Instead of only being able to edit essays,
you can edit any type of document you like, be it a math formula
cheatsheet, or a full page banner.

My history with Latex has been far from ideal, but I've come to terms
with the downsides enough that I can use it exclusively.  Here are the
pros and cons as far as I see it:

### Cons ###

* Learning a new language - Instead of using menus to apply formatting
  and styles to sections of a document, Latex uses tags to *describe*
  the semantics of the sections of document.  This requires the user
  to learn a set of tags and environments.

* Anti-visual - Latex's about as far from WYSIWYG as possible.  In
  fact, you can't even preview your document as your typing it.  Sure
  you can install an emacs mode for preview, and you could have 'xdvi'
  running to keep a continuous preview of your document, but the fact
  you have to 'compile' the document means an unavoidable wait.  If
  you're a person who can't work without a live preview, don't even
  bother with Latex.

* Anti-portable, Anti-collaboration - If your friends don't use Latex,
  hell, I'd be surprised if they've even heard of it, then you can
  only give them the unmodifiable output PDF.  They can't directly
  edit your draft as they would in Word and send it back to you.

* Focus on layout rather than semantics - Latex is the opposite of
  HTML in that you have to control every bit of formatting yourself.
  It really clutters up the document and isn't nearly as easy to
  maintain if the document is updated often.

### Pros ###

* Super-portable (output) - everyone worth talking to will be able to
  open PDFs.  You also be print-perfect output, everytime.

* Anti-bloat - choose your editor, compile when you feel like it.

* Semantic documents - the ability to restyle your document, but with
  more control than CSS offers.

### Common Commands ###

* \documentclass{article}
* \usepackage{fullpage, amsmath}
