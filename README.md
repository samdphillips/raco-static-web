# raco-static-web

A little raco command to serve some files on the web.  Inspired by the command
line mode of the python [http.server module](https://docs.python.org/3/library/http.server.html).

![screen shot](screenshot.png)

## Usage

1. Ensure `raco` is in your `$PATH`.
2. Open terminal in directory you want to serve.
  - Alternatively use the `-d` command line option to specify a directory.
3. Run `raco static-web` to serve the current directory.

For help and options use `raco help static-web`.

## Contributors:
 - [Ben Knoble](https://github.com/benknoble) : original code, directory listing, testing
 - [Ryan Culpepper](https://github.com/rmculpepper): command line
 - [Stephen De Gabrielle](https://github.com/spdegabrielle): docs
 - [Fred Fu](https://github.com/capfredf): docs
 - [Sorawee Porncharoenwase](https://github.com/sorawee): 404 page, upstream
   enhancements.
 - [Sam Phillips](https://github.com/samdphillips) : shepherding, packaging

file-line.png, folder-3-line.png, and folder-upload-line.png icons from the
[Remix Icon](https://github.com/Remix-Design/RemixIcon) project.

## Plans
Things I might add.  PRs welcome if you get to this before me.

 - [ ] MIME types and more icons
 - [ ] split out directory listing into separate package

