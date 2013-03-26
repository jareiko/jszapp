
# HTML5 Games Tech

## Audience Participation Platformer

JSZurich presentation on 2013-03-26.

### Structure

The app has three components: `server`, `control` and `display`.

There is also `common` code shared between all three.

`server` is a Node.js app. `control` and `display` are built with Brunch and run in the browser.

### Running

You'll need to have node+npm installed.

Start by cloning the repository:

    $ git clone https://github.com/jareiko/jszapp.git

Install dependencies:

    $ npm install

Run the server:

    $ coffee server/server.coffee

Then point your browser to:

    http://localhost:3000/

### Credits

* Rabbit by [Redshrike](http://opengameart.org/content/bunny-rabbit-lpc-style-for-pixelfarm)
* Longcat by [The Interwebs](http://www.funnyjunk.com/funny_pictures/3857954/Longcat/)
* Paintbrush by [Josh](http://openclipart.org/detail/116953/artists-paintbrush-by-jlawrence)
* WebGL logo by [Khronos](http://www.khronos.org/webgl/)
* Other gfx and sounds by @jareiko

### Technology

* [WebGL](http://www.khronos.org/webgl/)
* [Three.js](http://mrdoob.github.com/three.js/)
* [Backbone.js](http://backbonejs.org/)
* [Node.js](http://nodejs.org/)
* [CoffeeScript](http://coffeescript.org/)
