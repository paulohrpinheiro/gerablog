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

###  `-c` or `--create`

Create a new project:

    ➤ gerablog --create --root /tmp/teste
    /tmp/teste
    /tmp/teste/output
    /tmp/teste/texts
    /tmp/teste/templates

If `--root` is not informed, root will be `./`.

## `-g` or `--generate`

For my [blog](https://paulohrpinheiro.xyz):

    ➤ gerablog --generate --root ~/Dropbox/projetos/paulohrpinheiro.xyz/blog
    2016-12-24-nova-versao-do-ruby-txt2tags.html
    2016-12-16-ruby-e-o-deep-copy.html
    2016-11-08-iniciando-no-ruby.html
    2016-10-05-test-driven-development.html
    2016-11-03-colaborando-no-github.html
    2016-10-20-blogando-no-github.html
    2016-03-06-programacao-adlib.html
    2016-03-01-introducao_unqlite.html
    2016-02-02-resolucao-anonovo.html
    2015-10-27-bom-programador.html
    2015-08-27-cloud-agilidade-seguranca.html
    2015-08-16-porque-sistemas-nas-nuvens.html
    2015-08-15-consultoria-eficiente.html
    2015-08-12-startups-cto.html
    2015-07-30-o-cara-da-informatica.html
    2015-07-21-a-saga.html
    2015-07-17-na-nuvem-e-de-graca.html
    2014-10-04-uma-nuvenzinha.html
    2016-12-15-quase.html
    2016-05-31-sete-meses.html
    2016-05-23-a-marcha-do-tempo.html
    2016-05-16-hibernando.html
    2016-05-10-indicisao.html
    2016-05-03-mais-12-horas.html
    2016-04-26-vazio.html
    2016-04-19-sabotador.html
    2016-04-17-desconectado.html
    2016-04-12-super-poder.html
    2016-04-05-louco.html
    2016-04-01-tim-maia.html
    2016-03-31-horarios.html
    2016-03-31-depressao-ambiente-de-trabalho.html
    2016-03-30-a-cor-da-esperanca.html
    2016-03-29-fracassado.html
    2016-03-28-manoel-bandeira.html
    2016-03-28-mais-um-projeto.html
    2016-03-28-hora-de-dormir.html
    2016-03-28-desespero.html
    2016-11-05-comecando-em-javascript.html
    2015-12-13-dominando-jquery.html
    2016-03-08-goto-setjmp.html
    2016-02-17-testes-unitarios.html
    2015-09-22-perl-atualizado-openshift.html
    2015-08-22-fixtures-em-json-com-senha-criptografada-pelo-bcrypt.html
    2015-03-02-brincando-com-o-perl6.html
    2015-03-01-perl6-native-calling-support.html
    2016-12-07-refatorando-download-primeira.html
    2016-11-21-download-arquivos.html
    2016-11-17-lidando-com-erros-em-rust.html
    2016-11-16-testes-funcionais-em-rust.html
    2016-03-20-resolvendo-dns.html
    2016-03-09-filtro-unix.html
    2016-03-02-tirando-a-ferrugem.html
    2016-12-16-doctest-py2-e-py3.html
    2016-11-30-flask-esqueletico.html
    2016-02-06-numeros-aleatorios.html
    2015-10-15-usando-flask.html
    2015-02-23-tuplas-mutantes.html
    2014-09-28-sorted-containers.html

## Status

pre-alpha !

I'm using a ancestral script of this project to generate https://paulohrpinheiro.xyz.

The script is in this gist:

https://gist.github.com/paulohrpinheiro/20130e06355fc5bffe5865ce903dce63

Wait the beautiful code come in :)

More some days.

## TODO

- [ ] General RSS Feed
- [ ] By topic RSS feed
- [ ] Tests!!!!!
- [x] create project in command line
- [x] more complete command line options
- [ ] Gemfile
- [ ] Txt2tags support
