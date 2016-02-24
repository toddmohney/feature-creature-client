# feature-creature-client
Elm client for feature-creature cucumber visualization tool

![Feature Creature Client](http://static.tumblr.com/60f54be84b71e5e5e1e3a8f5e088e50c/b5bwnwn/expmtbzrf/tumblr_static_good3.jpg)

## Setup
1. Clone this repository.
2. Download and install Elm: http://elm-lang.org/install
3. To install all dependencies, run `elm-package install`. (on linux? see below)
4. Install the `feature-creature` project and follow the instructions to build it and run the web server: https://github.com/gust/feature-creature
5. Install Ruby dependencies with `bundle install`
5. Compile the main Elm file into Javascript, use the command: `elm make src/Main.elm --warn --output public/js/elm.js`. 
6. Run the application locally with `bundle exec rackup`

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
