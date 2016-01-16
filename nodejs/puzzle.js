// puzzle.js
// Based on https://darrenderidder.github.io/talks/ModulePatterns/#/9

var Puzzle = function () {};

Puzzle.prototype.header = function ( res, header ) {
	res.write(header);
}

exports.Puzzle = new Puzzle();
