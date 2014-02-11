<html>
    <head>
        <meta charset="utf-8">
        <meta content="IE=edge" http-equiv="X-UA-Compatible"/>
        <title>GDC</title>
        <link href="http://code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css" rel="stylesheet" type="text/css">
        <script src="http://maps.google.com/maps/api/js?v=3&amp;sensor=false"></script>
        <script src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
        <script src="http://code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
        <script src="http://www.openlayers.org/api/OpenLayers.js"></script>
        <script>
            $(function() {
            window.map = new OpenLayers.Map("mapdiv");
            var osm = new OpenLayers.Layer.OSM();
            var gmap = new OpenLayers.Layer.Google("Google Streets", {visibility: false});

            // note that first layer must be visible
            map.addLayers([osm, gmap]);

            map.addControl(new OpenLayers.Control.LayerSwitcher());
            map.zoomToMaxExtent();

            var zoom=16;

            var markers = new OpenLayers.Layer.Markers( "Markers" );
            map.addLayer(markers);
            map.setCenter ();



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
                        var date = new Date();
                        dateDevice = date.getUTCDate() + '-' + (date.getUTCMonth() + 1) + '-' + date.getUTCFullYear() + ' '
                            + date.getUTCHours() + ':' + date.getUTCMinutes() + ':' + date.getUTCSeconds() + ':' + date.getUTCMilliseconds()
                            + ' +0000';
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
                                    if (tmc1 > 50) {
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
                     var marker;
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
                            var lonLat = new OpenLayers.LonLat( res.lon ,res.lat )
                                  .transform(
                                    new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
                                    map.getProjectionObject() // to Spherical Mercator Projection
                                  );
                            if (marker) {
                                markers.removeMarker(marker);
                            }

                            marker = new OpenLayers.Marker(lonLat);

                            markers.addMarker(marker);

                            map.setCenter (lonLat, zoom);
                            getSimpleCallback(true, $(".getObjectPosition .resultText"))('lon: '+res.lon + ' lat' + res.lat + ' / duration:' + dur);
                        },
                        getSimpleCallback(false, $(".getObjectPosition .resultText")),
                        "json");
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
			            <input type="text" class="objectId" value="f2bc29b78c9c46719ea5aaeda2fcb245" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Device date (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="dateDevice" value="" />
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
			            <input type="text" class="objectId" value="f2bc29b78c9c46719ea5aaeda2fcb245" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Date time FROM (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="from" value="08-02-2014 10:00:00:000 +0400" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Date time TO (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="to" value="08-02-2014 10:01:00:000 +0400" />
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
			            <input type="text" class="objectId" value="f2bc29b78c9c46719ea5aaeda2fcb245" />
                    </td>
                </tr>
                <tr>
                    <td>
			            Date time BY (dd-MMM-yyyy hh:mm:ss:SSS ZZZ):
                    </td>
                    <td>
			            <input type="text" class="byDate" value="08-02-2014 10:01:00:000 +0400" />
                    </td>
                </tr>
			</table>
			<input type="button" value="get data" class="performBtn" />
			<div class="resultText"></div>
            <div id="mapdiv" style="height: 300px;width:500px;"></div>
 		</div>
    </body>
</html>
