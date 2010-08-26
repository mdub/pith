Pith
====

Pith is a static web-site generator, written in Ruby.

Using Pith, you can:

* __Express yourself succintly__ using Markdown or Textile.

* __Layout your pages__ written in ERb, [Haml][haml], or Liquid.

* __Style things up using__ [Sass][sass].

* __Encapsulate common markup__ in "layout" and "partial" templates.

* __Easily link pages and resources__ using relative links.

* __Quickly test changes__ using the built-in web-server.

* __Define custom helper-methods__ to increase expressiveness.

Why Pith?
---------

Why another static web-site generator, when there are other good options out there?  Pith's main differentiating factor is that structure of the output slavishly mirrors the structure of the input; there are no magic input directories for layouts, or dynamic content, or anything else.

Install it
----------

Pith is packaged as a Ruby gem.  Assuming you have Ruby, install it thusly:

    gem install pith

[tilt]: http://github.com/rtomayko/tilt/
[haml]: http://haml-lang.com
[sass]: http://sass-lang.com
