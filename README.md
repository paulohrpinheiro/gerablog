# GeraBlog

[![Gem Version](https://badge.fury.io/rb/gerablog.svg)](https://badge.fury.io/rb/gerablog)
[![Code Climate](https://codeclimate.com/github/paulohrpinheiro/gerablog/badges/gpa.svg)](https://codeclimate.com/github/paulohrpinheiro/gerablog)
[![Test Coverage](https://codeclimate.com/github/paulohrpinheiro/gerablog/badges/coverage.svg)](https://codeclimate.com/github/paulohrpinheiro/gerablog)
[![Issue Count](https://codeclimate.com/github/paulohrpinheiro/gerablog/badges/issue_count.svg)](https://codeclimate.com/github/paulohrpinheiro/gerablog)
![travis-CI](https://api.travis-ci.org/paulohrpinheiro/gerablog.svg?branch=master)

*Blog Generator - my own static site generator*

Write in *Markdown*, publish in *HTML*.

![I'm GeraBlog](gerablog.png)
*Image created by https://robohash.org/*

## Rules

* The texts must be written in markdown.
* The first line of file will be the post title `#` mark.
* The second line is a blank line.
* The third line will be the description of text, with `##` mark. Will be in meta description of generated html.
* The filename **MUST** begin with a date: `2016-12-31-this-is-a-post.md`.
* The texts must be in a subdirectory of `texts`. Each subdirectory will be assigned a *category*.
* Change the layout by changing files in `templates` dir, which uses [Tenjin](http://www.kuwata-lab.com/tenjin/rbtenjin-users-guide.html) as template system.
* `JS` and` CSS` files put in `assets/{css, js}`.
* The images used in the posts should be placed in a `images` subdirectory, within the category directory:` texts/ruby/images/pinkpanter.jpg`. In the post, put the reference as `![Pink Panter](images/pinkpanter.jpg)`.
* Images used in posts **MUST** be placed in the same level`CATEGORY/images`.
* By default, *GeraBlog* uses [prism](http://prismjs.com/) to highlight the syntax of the codes. The language indicated will be the category in which the text is. For example, the file `ruby/2016-12-31-ruby-rocks.md` if it has some source code, it will be marked as *lang-ruby*.

## Sample text:

    # This is the title

    ## This is the description

    Here the text.

    Show-me the code:

        puts 'Hello world!'

## Install

    gem install gerablog

## Hacking

* clone the repo;
* `bundle install`;
* make changes (with tests!)
* run all the tests (`rake`) and fix anything that appears wrong
* run `rubocop` and fix all *offenses*!
* send me a PR.

## Using

The executable `gerablog` has this options:

### `-h` or `--help`

Yes, we have a `--help` option:

    ➤ gerablog --help
    Usage: optparse [options]
        -h, --help                       Display this screen
        -n, --new FILENAME               Create a new project.
        -g, --generate FILENAME          Generate the static blog.

###  `-n` or `--new`

Create a new project:

    ➤ gerablog --new /tmp/test

How the project looks like?

    ➤ tree /tmp/test
    /tmp/test
    ├── assets
    │   └── assets
    │       ├── css
    │       │   ├── gerablog.css
    │       │   └── prism.css
    │       └── js
    │           └── prism.js
    ├── gerablog.conf
    ├── output
    ├── templates
    │   └── templates
    │       ├── categories.rbhtml
    │       ├── category.rbhtml
    │       ├── feed.rbxml
    │       ├── footer.rbhtml
    │       ├── header.rbhtml
    │       ├── index.rbhtml
    │       └── post.rbhtml
    └── texts

If `--root` is not informed, root will be `./`.

### `-g` or `--generate`

### Deploy

For my [blog](https://paulohrpinheiro.xyz):

    ➤ gerablog --generate ~/Dropbox/projetos/paulohrpinheiro.xyz/blog/gerablog.conf
    ruby
    diversos
    programadorbipolar
    javascript
    c
    perl
    rust
    python

Copy `output` directory to your server :)

## History

This project started with a script I made to generate my site https://paulohrpinheiro.xyz.

The script is in this gist:

https://gist.github.com/paulohrpinheiro/20130e06355fc5bffe5865ce903dce63
