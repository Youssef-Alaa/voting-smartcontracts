const moment = require('moment');

var ts = moment("9/7/2020 13:48", "M/D/YYYY H:mm").unix();
var m = moment(ts);
var s = m.format("M/D/YYYY H:mm");
console.log("Values are: ts = " + ts + ", s = " + s);