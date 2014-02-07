<html>
    <head>
        <meta charset="utf-8">
        <meta content="IE=edge" http-equiv="X-UA-Compatible"/>
        <title>GDC</title>
        <link href="http://code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css" rel="stylesheet" type="text/css">
        <script src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
        <script src="http://code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
        <script>
            $(function() {

                function ajax(byUrl, method, success, error, dataType) {
                    jQuery.ajax({
                        url: byUrl,
                        type: method,
                        dataType: dataType,
                        success: function(data, textStatus,  jqXHR) {
                            if (success) success(data);
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            if (error) error(jqXHR.responseText);
                        }
                    });
                }
                function postAjax(byUrl, method, dataType) {
                    var xhr = jQuery.ajax({
                        url: byUrl,
                        type: method,
                        dataType: dataType
                    });
                    setTimeout(function() {
                        xhr.abort();
                    }, 100);
                }
                function getSimpleCallback(success, $resultDisplay) {
                    return function(res) {
                        if ($resultDisplay) {
                            if (success) {
                                //success
                                $resultDisplay.text("success" + (res ? ": "+res : ""));
                            }
                            else {
                                //error
                                $resultDisplay.text("error: " + res);
                            }
                            $resultDisplay.effect( "bounce", null, 500 );
                        }
                    };
                }
                $('.addGeoDataPane .performBtn').click(function() {
                    var objectId = $(".addGeoDataPane .objectId").val();
                    if (!objectId || objectId == "") {
                        $(".addGeoDataPane .objectId").effect( "bounce", null, 500 );
                        return;
                    }
                    var dateDevice = $(".addGeoDataPane .dateDevice").val();
                    if (!dateDevice || dateDevice == "") {
                        $(".addGeoDataPane .dateDevice").effect( "bounce", null, 500 );
                        return;
                    }
                    var lon = $(".addGeoDataPane .lon").val();
                    if (!lon || lon == "") {
                        $(".addGeoDataPane .lon").effect( "bounce", null, 500 );
                        return;
                    }
                    var lat = $(".addGeoDataPane .lat").val();
                    if (!lat || lat == "") {
                        $(".addGeoDataPane .lat").effect( "bounce", null, 500 );
                        return;
                    }
                    var speed = $(".addGeoDataPane .speed").val();
                    var degree = $(".addGeoDataPane .degree").val();
                    ajax("data/addGeoData?"
                        + "objectId="+encodeURIComponent(objectId)
                        + "&dateDevice="+encodeURIComponent(dateDevice)
                        + "&lon="+encodeURIComponent(lon)
                        + "&lat="+encodeURIComponent(lat)
                        + ((!speed || speed == "") ? "" : "&speed="+encodeURIComponent(speed))
                        + ((!degree || degree == "") ? "" : "&degree="+encodeURIComponent(degree)),
                        'GET',
                        getSimpleCallback(true, $(".addGeoDataPane .resultText")),
                        getSimpleCallback(false, $(".addGeoDataPane .resultText")),
                        "text");
                });

                var timers = [];
                var started = false;
                $('.addRandomGeoDataPane .stopBtn').click(function() {
                    for (var i = 0; i < timers.length; i++)
                        timers[i].active = false;
                        started = false;
                });
                $('.addRandomGeoDataPane .startBtn').click(function() {
                    if (!started) $(".addRandomGeoDataPane .intervals").empty();
                    started = true;
                    var objectIds = $(".addRandomGeoDataPane .objectId").val().split('\n');
                    $.each(objectIds, function (k,objectId) {
                        var timer = {
                            active: true
                        };
                        if (!objectId || objectId == "") return;
                        timer.$el = $('<div>');
                        timer.$el.appendTo($(".addRandomGeoDataPane .intervals"));
                        var count = 0;
                        var avgt = 0;

                        var tmc1 = 0;
                        var tmcs = 0;

                        var interval = parseInt($(".addRandomGeoDataPane .interval").val());
                        if (!interval || interval <= 0) interval = 1000;

                        function getRandomArbitary(min, max)
                        {
                          return Math.random() * (max - min) + min;
                        }

                        function addData() {
                            var date = new Date();
                            var dateDevice = date.getUTCDate() + '-' + (date.getUTCMonth() + 1) + '-' + date.getUTCFullYear() + ' '
                                + date.getUTCHours() + ':' + date.getUTCMinutes() + ':' + date.getUTCSeconds() + ':' + date.getUTCMilliseconds()
                                + ' +0000';
                            var lon = getRandomArbitary(30, 31);
                            var lat = getRandomArbitary(60, 61);
                            var start = new Date();
/*
                            postAjax("data/addGeoData?"
                                + "objectId="+encodeURIComponent(objectId)
                                + "&dateDevice="+encodeURIComponent(dateDevice)
                                + "&lon="+encodeURIComponent(lon)
                                + "&lat="+encodeURIComponent(lat),
                                'GET',"text");
                            count = count + 1;
                            timer.$el.text(objectId + ": added: " + count + " recs");
*/
                            ajax("data/addGeoData?"
                                + "objectId="+encodeURIComponent(objectId)
                                + "&dateDevice="+encodeURIComponent(dateDevice)
                                + "&lon="+encodeURIComponent(lon)
                                + "&lat="+encodeURIComponent(lat),
                                'GET',
                                function () {
                                    tmc1 = tmc1 + 1;
                                    tmcs = tmcs + (new Date() - start);
                                    avg = tmcs / tmc1;
                                    if (tmc1 > 10) {
                                        tmc1 = 0;
                                        tmcs = 0;
                                    }
                                    count = count + 1;
                                    timer.$el.text(objectId + ": added: " + count + " recs, avg response: " + Math.round(avg) + " ms");
                                    if (timer.active)
                                        setTimeout(addData,0)
                                },
                                function (res) {

                                    getSimpleCallback(false, $(".addRandomGeoDataPane .resultText"))(res);
                                },
                                "text");
                        }
                        timers.push(timer);
                        setTimeout(addData,0)
                    });

                });
                $('.getObjectTrack .performBtn').click(function() {
                    var objectId = $(".getObjectTrack .objectId").val();
                    if (!objectId || objectId == "") {
                        $(".getObjectTrack .objectId").effect( "bounce", null, 500 );
                        return;
                    }
                    var from = $(".getObjectTrack .from").val();
                    if (!from || from == "") {
                        $(".getObjectTrack .from").effect( "bounce", null, 500 );
                        return;
                    }
                    var to = $(".getObjectTrack .to").val();
                    if (!to || to == "") {
                        $(".getObjectTrack .to").effect( "bounce", null, 500 );
                        return;
                    }
                    ajax("data/getObjectTrack?"
                        + "objectId="+encodeURIComponent(objectId)
                        + "&from="+encodeURIComponent(from)
                        + "&to="+encodeURIComponent(to),
                        'GET',
                        getSimpleCallback(true, $(".getObjectTrack .resultText")),
                        getSimpleCallback(false, $(".getObjectTrack .resultText")),
                        "text");
                });
                $('.getObjectPosition .performBtn').click(function() {
                    var objectId = $(".getObjectPosition .objectId").val();
                    if (!objectId || objectId == "") {
                        $(".getObjectPosition .objectId").effect( "bounce", null, 500 );
                        return;
                    }
                    var byDate = $(".getObjectPosition .byDate").val();
                    var start = new Date();
                    ajax("data/getObjectPosition?"
                        + "objectId="+encodeURIComponent(objectId)
                        + (byDate && byDate != "" ? "&byDate="+encodeURIComponent(byDate) : ""),
                        'GET',
                        function (res) {
                            var dur = new Date() - start;
                            getSimpleCallback(true, $(".getObjectPosition .resultText"))(res + ' / duration:' + dur);
                        },
                        getSimpleCallback(false, $(".getObjectPosition .resultText")),
                        "text");
                });
            });
        </script>
    </head>
    <body>
        <h2>Geo Data Collect demo</h2>
        <div class="addGeoDataPane">
			<h3><p>Add user:</h3>
			<table>
                <tr>
                    <td>
			            Object id:
                    </td>
                    <td>
			            <input type="text" class="objectId" value="8271ed7f1abe4dc19c8f056820f6fdca" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Device date (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="dateDevice" value="05-02-2014 00:00:00:000 +0000" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Longitude:
                    </td>
                    <td>
			            <input type="text" class="lon" value="30" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Latitude:
                    </td>
                    <td>
			            <input type="text" class="lat" value="60" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Speed:
                    </td>
                    <td>
			            <input type="text" class="speed" value="10" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Degree:
                    </td>
                    <td>
			            <input type="text" class="degree" value="0" />
                    </td>
                </tr>
			</table>
			<input type="button" value="add data" class="performBtn" />
			<div class="resultText"></div>
		</div>
        <div class="addRandomGeoDataPane">
			<h3><p>Add user:</h3>
			<table>
                <tr>
                    <td>
			            Object IDs, one per line:
                    </td>
                    <td>
			            <textarea class="objectId"></textarea>
                    </td>
                </tr>
                <tr>
                    <td>
			            Interval, ms:
                    </td>
                    <td>
			            <input type="text" class="interval" value="1000" />
                    </td>
                </tr>
			</table>
			<input type="button" value="start feeding data" class="startBtn" />
			<input type="button" value="stop feeding data" class="stopBtn" />
			<div class="intervals"></div>
			<div class="resultText"></div>
		</div>
        <div class="getObjectTrack">
			<h3><p>Get object track:</h3>
			<table>
                <tr>
                    <td>
			            Object id:
                    </td>
                    <td>
			            <input type="text" class="objectId" value="8271ed7f1abe4dc19c8f056820f6fdca" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Date time FROM (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="from" value="01-01-2014 00:00:00:000 +0000" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Date time TO (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="to" value="01-01-2015 00:00:00:000 +0000" />
                    </td>
                </tr>
			</table>
			<input type="button" value="get data" class="performBtn" />
			<div class="resultText"></div>
		</div>
        <div class="getObjectPosition">
			<h3><p>Get object position:</h3>
			<table>
                <tr>
                    <td>
			            Object id:
                    </td>
                    <td>
			            <input type="text" class="objectId" value="8271ed7f1abe4dc19c8f056820f6fdca" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Date time BY (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="byDate" value="01-01-2015 00:00:00:000 +0000" />
                    </td>
                </tr>
			</table>
			<input type="button" value="get data" class="performBtn" />
			<div class="resultText"></div>
		</div>
    </body>
</html>
