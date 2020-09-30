const moment = require('moment');

var ts = "9/26/2020 18:48";
var seconds = parseInt(((moment(ts, "M/D/YYYY H:mm").valueOf()) / 1000).toFixed(0));
console.log("seconds",seconds, typeof(seconds));

var date = moment(ts,"M/D/YYYY H:mm");
var iso = date.format();
console.log("iso:", iso);
var m = moment(seconds * 1000);
var s = m.format("M/D/YYYY H:mm");
console.log("s=", s);