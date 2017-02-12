<html>
<head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
    <script src="https://code.highcharts.com/highcharts.js"></script>
</head>
<body>
<script type="text/javascript">
    $(function () {
        Highcharts.setOptions({
            global: {
                timezoneOffset: new Date().getTimezoneOffset()
            }
        });

    Highcharts.chart('container', {
            chart: {
                type: 'spline'
            },
            title: {
                text: 'Temperature Sensors'
            },
//            subtitle: {
//                text: 'Irregular time data in Highcharts JS'
//            },
            xAxis: {
                type: 'datetime',
                dateTimeLabelFormats: { // don't display the dummy year
                    millisecond: "%A, %b %e, %H:%M:%S.%L",
                    second: "%A, %b %e, %H:%M:%S",
                    minute: "%A, %b %e, %H:%M",
                    hour: "%A, %b %e, %H:%M",
                    day: "%A, %b %e, %Y",
                    week: "Week from %A, %b %e, %Y",
                    month: "%B %Y",
                    year: "%Y"
                },
                title: {
                    text: 'Date'
                }
            },
            yAxis: {
                title: {
                    text: 'Degrees °F'
                },
                min: 40
//                max: 120
            },
            tooltip: {
                headerFormat: '<b>{series.name}</b><br>',
                pointFormat: '{point.x:%H:%M}: {point.y:.2f} F'
            },

            plotOptions: {
                spline: {
                    marker: {
                        enabled: true
                    }
                }
            },

            series: [
                <?php
                include('config.php');

                $days = ($_GET['days'] > 0) ? $_GET['days'] : 0.5;
                $days_in_secs = $days  * 24 * 60 * 60;
                $step = ($_GET['step'] > 0) ? $_GET['step'] : 3;


                mysql_connect($host . ':' . $port, $user, $pass);
                mysql_select_db($name);
                $sensors_result = mysql_query('SELECT sensor_id, sensor_name FROM sensors');

                $i=0;
                while ($i < mysql_numrows($sensors_result)) {
                    if ($i > 0) print ',';

                    $sensor_id = mysql_result($sensors_result, $i, 'sensor_id');
                    $sensor_name = mysql_result($sensors_result, $i, 'sensor_name');

                    print '{';
                    print 'name: "' . $sensor_name . '",';
                    print 'data: [';

                    $data_query = sprintf("SELECT epoch_timestamp, temp_reading FROM data WHERE sensor_id = '%s' AND epoch_timestamp > '%s' ORDER BY epoch_timestamp DESC", $sensor_id, time() - $days_in_secs);
                    $data_result = mysql_query($data_query);
                    $j=0;
                    while ($j < mysql_numrows($data_result)) {
                        $epoch_timestamp = mysql_result($data_result, $j, 'epoch_timestamp');
                        $temp_reading = mysql_result($data_result, $j, 'temp_reading');
                        print '[' . $epoch_timestamp . '000, ' . $temp_reading . '],';
                        $j += $step;
                    }
                    print ']';
                    print "}\n";

                    $i++;
                }
                ?>
            ]
        });
    });
</script>
<div id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
</body>
</html>