

function CountDownTimer(dt, id)
{
    var end = new Date(dt);
    var _second = 1000;
    var _minute = _second * 60
;        var _hour = _minute * 60;
    var _day = _hour * 24;
    var timer;

    function showRemaining() {
        var now = new Date();
        var distance = end - now;
        if (distance < 0) {

            clearInterval(timer);
            document.getElementById("answer").style.visibility = "hidden";
            document.getElementById(id).innerHTML = '<img src="https://i.imgur.com/tY60H5X.gif">';
            document.getElementById("until").style.visibility = "hidden";

            return;
        }
        var days = Math.floor(distance / _day);
        var hours = Math.floor((distance % _day) / _hour);
        var minutes = Math.floor((distance % _hour) / _minute);
        var seconds = Math.floor((distance % _minute) / _second);

        document.getElementById(id).innerHTML = days + ' days ';
        document.getElementById(id).innerHTML += hours + ':';
        document.getElementById(id).innerHTML += minutes + ':';
        document.getElementById(id).innerHTML += seconds + '';
    }

    timer = setInterval(showRemaining, 1000);
}

var c = '08/03/2019 03:00 PM'
CountDownTimer(c, 'lefttogo');

// window.onload = function() {
//     document.getElementById('until').innerHTML = c;
// };
