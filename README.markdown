Pith
====

Pith is a static website generator, written in Ruby.

Using Pith, you can:

* Lay-out your page designs in [Haml][haml], ERb, or Liquid.
* Style things up using [Sass][sass].
* Succintly add content using Markdown or Textile.
* Encapsulate common markup in "layout" and "partial" templates.
* Easily link pages (and resources) using relative links.
* Test changes quickly using the built-in web-server.

Install it
----------

Pith is packaged as a Ruby gem.  Assuming you have Ruby, install it thusly:

    gem install pith

Quickstart
----------

Create an input directory for your site (wherever you want), and pop some files into it:

    SITE/
      _pith/
      images/
        logo.png
      index.html.haml

The only requirement is the existance of a subdirectory called "`_pith`".  Pith checks that it's present, to prevent you accidently treating your entire home directory as website input.

Next, use the `pith build` command to convert your inputs into a functioning website.

    $ pith -i SITE build
    Generating to "SITE/_out"
    --(copy)-->   images/logo.png
    --(haml)-->   index.html

By default, output is generated into an subdirectory called "`_out`", inside the input directory ... but the default can be easily overridden, e.g.

    $ pith -i SITE -o OUTPUT build

Templates
---------

Files in the input directory are considered to be "templates" if the file name ends with a template format extension recognised as such by [Tilt][tilt], e.g. "`.haml`", or "`.textile`".  These will be evaluated dynamically.  Pith strips the format extension off the file name when generating output.

Formats supported by Tilt include:

- [Markdown](http://daringfireball.net/projects/markdown/) (`markdown`, `md`)
- [Textile](http://redcloth.org/hobix.com/textile/) (`textile`)
- [Haml][haml] (`haml`)
- [Erb](http://ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html) (`erb`)
- [Sass][sass] (`sass`)
- [CoffeeScript](http://jashkenas.github.com/coffee-script/) (`coffee`)

Any non-template input files (we call them "resources") are just copied verbatim into the output directory.

Ignored files
-------------

Files or directories beginning with an underscore are ignored; that is, we don't generate corresponding output files.  They can still be used as "layout" or "partial" templates though; see below.

Page metadata
-------------

A YAML header can be provided at the top of any template, defining page metadata.  The header is introduced by a first line containing three dashes, and terminated by a line containing three dots.

    ---
    title: "All about fish"
    ...

Metadata provided in the header can be referenced by template content, via the "`page.meta`" Hash:

    %html
      %head
        %title= page.meta["title"]
      %body
        %h1= page.meta["title"]

This is especially useful in "layout" templates (see below).
    
Partials and Layouts
--------------------

Templates can include other templates, e.g.

     = include "_header.haml"

When including, you can pass local variables, e.g.

    = include "_list.haml", :items => [1,2,3]

which can be accessed in the included template:

    %ul
      - items.each do |i|
        %li= i

In Haml templates, you can also pass a block, e.g.

    = include "_mylayout.haml" do
      %p Some content

and access it in the template using "`yield`":

    !!!
    %html
      %body
        .header
          ... blah blah ...
        .main
          = yield

This way, any template can be used as a "layout".

Layouts can also be applied by using a "`layout`" entry in the page header, e.g.

    ---
    layout: "/_mylayout.haml"
    ...

    Some content

Relative links
--------------

It's sensible to use relative URIs when linking to other pages (and resources) in your static site, making the site easier to relocate.  But generating relative-links from partials and layouts is tricky.  Pith makes it easy with the "`href`" function:

    %a{:href => href("other.html")} Other page

    %img{:src => href("/images/logo.png")}

Any path beginning with a slash ("/") is resolved relative to the root of the site; anything else is resolved relative to the current input-file (even if that happens to be a layout or partial).  Either way, "`href`" always returns a relative link.

There's also a "`link`" function, for even easier hyper-linking:

    link("other.html", "Other page")
    
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
