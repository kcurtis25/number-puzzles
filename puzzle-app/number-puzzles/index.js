
'use strict'

var Puzzle = function () {};

Puzzle.prototype.getPuzzleTypes = function() {
	var types = [ 'Addition', 'Subtraction' ];
	return types;
}

module.exports = new Puzzle();

