var express   = require('express');
var router    = express.Router();

/* GET show generate form */
router.get('/', function(req, res, next) {
	res.render('generate-form');
});

/* POST - After the user submits the form */
router.post('/', function(req, res, next) {
	res.send('user has submitted the form. See console log for details');
	console.log(req.body);
});

module.exports = router;
