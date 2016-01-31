var express   = require('express');
var router    = express.Router();
var puzzle    = require('../number-puzzles/index.js');

/* GET show generate form */
router.get('/', function(req, res, next) {
	var types = puzzle.getPuzzleTypes();
	res.render('generate-form', { types: types });
});

/* POST - After the user submits the form */
router.post('/', function(req, res, next) {
	res.send('user has submitted the form. See console log for details');
	console.log(req.body);
});

module.exports = router;
