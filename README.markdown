Pith
====

Pith is a static web-site generator, written in Ruby.

Using Pith, you can:

* Lay-out your page designs in [Haml][haml], ERb, or Liquid.

* Style things up using [Sass][sass].

* Succintly add content using Markdown or Textile.

* Encapsulate common markup in "layout" and "partial" templates.

* Easily link pages (and resources) using relative links.

* Test changes quickly using the built-in web-server.

Why Pith?
---------

Why another static web-site generator, when there are other good options out there?  Pith's main differentiating factor is that structure of the output slavishly mirrors the structure of the input; there are no magic input directories for layouts, or dynamic content, or anything else.

Install it
----------

Pith is packaged as a Ruby gem.  Assuming you have Ruby, install it thusly:

    gem install pith

Quickstart
----------

Create an input directory for your site (wherever you want), and pop some files into it:

    SITE/
      images/
        logo.png
      index.html.haml

Use the `pith build` command to convert your inputs into a functioning website.

    $ pith -i SITE build
    Generating to "SITE/_out"
    --(copy)-->   images/logo.png
    --(haml)-->   index.html

Any input file with an extension recognised by [Tilt][tilt] is considered to be a template, and will be dynamically evaluated.  Anything else is just copied verbatim into the generated site.

Built-in web-server
-------------------

For quick prototyping, pith includes a simple HTTP server.  Start it by using the "`serve`" command, rather than "`build`"

    $ pith -i SITE serve
    Generating to "SITE/_out"
    --(copy)-->   images/logo.png
    --(haml)-->   index.html
    Taking the Pith at "http://localhost:4321"
    >> Thin web server (v1.2.7 codename No Hup)
    >> Maximum connections set to 1024
    >> Listening on 0.0.0.0:4321, CTRL+C to stop

Pith will incrementally re-build the site as you browse -- that is, if you alter any input files, Pith will regenerate the affected outputs.

[tilt]: http://github.com/rtomayko/tilt/
[haml]: http://haml-lang.com
[sass]: http://sass-lang.com
