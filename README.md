# GeraBlog

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
* Change the layout by changing the `templates/posts.html.erb` file, which uses [erubis](http://www.kuwata-lab.com/erubis/) as template system.
* `JS` and` CSS` files put in `assets/{css, js}`.
* The images used in the posts should be placed in a `images` subdirectory, within the category directory:` texts/ruby/images/pinkpanter.jpg`. In the post, put the reference as `![Pink Panter](images/pinkpanter.jpg)`.
* Images used in posts **MUST** be placed in the same level`CATEGORY/images`.
* By default, *GeraBlog* uses [prism](http://prismjs.com/) to highlight the syntax of the codes. The language indicated will be the category in which the text is. For example, the file `ruby/2016-12-31-ruby-rocks.md` if it has some source code, it will be marked as *lang-ruby*.

# Sample text:

    # This is the title

    ## This is the description

    Here the text.

    Show-me the code:

        puts 'Hello world!'

## Using

The binary `gerablog` has this options:

### `-h` or `--help`

Yes, we have a `--help` option:

    ➤ gerablog --help
    Usage: optparse [options]
        -h, --help                       Display this screen
        -r FILENAME (default './'),      Root dir for project
            --root
        -c, --create                     Create a new project
        -g, --generate                   Generate the static blog.

###  `-n` or `--new`

Create a new project:

    ➤ gerablog --new --root /tmp/test

How the project looks like?

    ➤ tree /tmp/test
    /tmp/test
    ├── gerablog.conf
    ├── output
    ├── templates
    │   └── templates
    │       ├── categories.html.erb
    │       ├── feed.xml.erb
    │       └── post.html.erb
    └── texts

If `--root` is not informed, root will be `./`.

## `-g` or `--generate`

For my [blog](https://paulohrpinheiro.xyz):

    ➤ gerablog --generate --conf ~/Dropbox/projetos/paulohrpinheiro.xyz/blog/gerablog.conf
    ruby
    diversos
    programadorbipolar
    javascript
    c
    perl
    rust
    python

## Status

pre-alpha !

I'm using a ancestral script of this project to generate https://paulohrpinheiro.xyz.

The script is in this gist:

https://gist.github.com/paulohrpinheiro/20130e06355fc5bffe5865ce903dce63

Wait the beautiful code come in :)

More some days.

## TODO

- [x] General RSS Feed
- [x] By topic RSS feed
- [ ] Tests!!!!!
- [x] create project in command line
- [x] more complete command line options
- [ ] Gemfile
- [ ] Txt2tags support
