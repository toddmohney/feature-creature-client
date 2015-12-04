# feature-creature-client
Elm client for feature-creature cucumber visualization tool

![Feature Creature Client](http://static.tumblr.com/60f54be84b71e5e5e1e3a8f5e088e50c/b5bwnwn/expmtbzrf/tumblr_static_good3.jpg)

## Setup
1. Clone this repository.
2. Download and install Elm: http://elm-lang.org/install
3. To install all dependencies, run `elm-package install`. (on linux? see below)
4. Install the `feature-creature` project and follow the instructions to build it and run the web server: https://github.com/gust/feature-creature
5. In order to compile the main Elm file into Javascript, use the command: `elm make src/Main.elm --warn --output elm.js`. This will compile to `elm.js` by default.
6. To run the application locally, view `main.html` directly in your browser. Or for a hot-swapping version, run `elm-reactor` and visit `localhost:8000`.

_Note: The elm-reactor debugger is currently not compatible with ports, which are used in the application. Nothing we can do about that, unfortunately. We'll look into alternatives._

## Ubuntu Install
* Install a recent version of node and npm https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions

  _Note: if you have trouble installing `nodejs-legacy` move on without it._
* Install elm via npm `sudo npm install -g elm`
* Confirm elm installed properly by running `elm-repl`
* If you receive an error about `index.js` have a gander at https://github.com/elm-lang/elm-platform/issues/100 and do the following:
  * `sudo npm uninstall -g elm`
  * `sudo npm install -g elm@2.0.0`
  * confirm elm installed properly by running `elm-repl`
