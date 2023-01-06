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

## Changelog
### 1.1.0
Release date: 2023/01/06
- Add the `--launch` option to open a browser after starting.

## 1.0.1
Release date: 2022/09/22
- Use response logging
- Support for content-encoding: gzip

## 1.0.0
Release date: 2022/06/05
- Add content-type headers
- Use a non non-blank 404
- Add favicon

## 0.9.9
Release date: 2021/11/03
- Initial release

## Contributors:
 - [Ben Knoble](https://github.com/benknoble) : original code, directory
   listing, testing
 - [Ryan Culpepper](https://github.com/rmculpepper): command line
 - [Stephen De Gabrielle](https://github.com/spdegabrielle): docs
 - [Joel Dueck](https://github.com/otherjoel): `--launch` option
 - [Fred Fu](https://github.com/capfredf): docs
 - [Sorawee Porncharoenwase](https://github.com/sorawee): 404 page, upstream
   enhancements, response logging, gzip content encoding
 - [Sam Phillips](https://github.com/samdphillips) : shepherding, packaging

file-line.png, folder-3-line.png, and folder-upload-line.png icons from the
[Remix Icon](https://github.com/Remix-Design/RemixIcon) project.

## Plans
Things I might add.  PRs welcome if you get to this before me.

 - [ ] MIME types and more icons
 - [ ] split out directory listing into separate package

