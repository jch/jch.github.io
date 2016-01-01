# Emacs Refactoring #

While I waited for Coupa customers to be upgraded, I decided to clean
up my .emacs config file.  My .emacs was never a pretty thing to
admire.  Without any restraint, I often added whatever cool code
snippet I came across online.  The file became verbose, redundant, and
a general mess. I set out to make it more modular and easier to
follow.

The first thing I wanted to fix was this really ugly section where I
manipulate the <code>load-path</code> and load my plugins. I created a
convention to install each plugin in it's own folder, and to have a
install hook for each plugin. For example, the ruby plugin looks like:

    ~/.emacs.d/plugins
      ruby
        ruby.el
        load-ruby.el

Previously, I added the following 2 lines for every plugin.

    (add-to-list 'load-path "~/.emacs.d/plugins/ruby")
    (load "load-ruby.el")

But thanks to the
[EmacsWiki](http://www.emacswiki.org/emacs/LoadPath), I learned about
<code>normal-top-level-add-to-load-path</code>. In the finished
version, I put the plugin names in a list and iterate over them:

    ;;; ### Plugin Initialization ###
    (setq plugins-to-load
      '("harvey-navigation" "javascript" "dsvn" "ruby" "ido"))

    ;; add to "~/.emacs.d/plugins/__plugins-to-load__ to load-path
    (let* ((my-lisp-dir "~/.emacs.d/plugins")
           (default-directory my-lisp-dir))
      (setq load-path (cons my-lisp-dir load-path))
      (normal-top-level-add-to-load-path plugins-to-load))

    ;; run the init file for the plugin
    (mapcar (lambda (plugin-name)
              (load (concat "load-" plugin-name ".el")))
            plugins-to-load)

In the process of changing how plugins are loaded, I removed several
plugins that I never used. This lowered my emacs load time by a large
perceptible amount.

My .emacs isn't something I work with very often, but I derived a fair
amount of satisfaction that the next time I need to tweak something,
I'll know it won't suck.

You can find the finished config [here](http://github.com/jch/jch-dotfiles/tree/master/emacs).
