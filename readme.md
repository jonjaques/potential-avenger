# Potential Avenger

## Dependencies

- [Node.js](0)
- [GraphicksMagick](1) (ImageMagick is possible but not supported right now)

## Project Setup

After cloning, run `npm install`

## Commands

- `gulp report` Produces a time-stamped report of all the images in the `src` directory, where each image size & ratio is tallied

- `gulp trim` Crops the whitespace around each image in `src` by trimming away the most prominent corner colors. Applies some logic to keep the same quality for JPGs.

[0]: http://nodejs.org/
[1]: http://www.graphicsmagick.org/
