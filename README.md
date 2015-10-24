# feature-creature-client
Elm client for feature-creature cucumber visualization tool

![Feature Creature Client](http://static.tumblr.com/60f54be84b71e5e5e1e3a8f5e088e50c/b5bwnwn/expmtbzrf/tumblr_static_good3.jpg)

## Setup
1. Clone this repository.
2. Download and install Elm: http://elm-lang.org/install
3. To install all dependencies, run `elm-package install`.
4. In order to compile the main Elm file into Javascript, use the command: `elm-make FeatureCreature.elm`. This will compile to `elm.js` by default.
5. To run the application locally, view `main.html` directly in your browser. Or for a hot-swapping version, run `elm-reactor` and visit `localhost:8000`.

_Note: The elm-reactor debugger is currently not compatible with ports, which are used in the application. Nothing we can do about that, unfortunately. We'll look into alternatives._
