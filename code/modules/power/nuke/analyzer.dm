/obj/machinery/power/nuke_analyzer
	var/html = {"<!doctype html>
<html>

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Nuclear Material Analyzer</title>
	<link rel="stylesheet" type="text/css" href="[resource("css/bootstrap.min.css")]">
    <link rel="stylesheet" type="text/css" href="[resource("css/bootstrap.min.css")]">
    <link rel="stylesheet" type="text/css" href="[resource("css/bootstrap-responsive.min.css")]">
	<link rel="stylesheet" type="text/css" href="[resource("css/computer-nukeanalyzer.css")]">
    <script type="text/javascript" src="[resource("js/jquery.min.js")]"></script>
    <script type="text/javascript" src="[resource("js/jquery.migrate.js")]")></script>
</head>

<body>
    <script type="text/javascript" src="[resource("js/bootstrap.min.js")]"></script>
    <script type="text/javascript" src="[resource("js/jsviews.min.js")]"></script>

	<div id="stats_header"><span class="nav_active">nuclear material analysis computer</span></div>

	<div class="ib left-pane">
		<span class="nuke-pane-header">Properties:</span><br />
		<span class="nuke-prop-name">Name:</span><span class="nuke-name">-</span><br />
		<span class="nuke-prop-name">Classification:</span><span class="nuke-class">-</span><br />
		<span class="nuke-prop-name">Quality:</span><span class="nuke-quality">-</span><br />
		<span class="nuke-prop-name">Partice Type:</span><span class="nuke-particle">-</span><br />
		<span class="nuke-prop-name">Emissivity:</span><span class="nuke-epv">-</span><br />
		<span class="nuke-prop-name">Thermal Volatility:</span><span class="nuke-hpe">-</span><br />
		<span class="nuke-prop-name">Absorptivity:</span><span class="nuke-absorb">-</span><br />
		<span class="nuke-prop-name">Excitability:</span><span class="nuke-kfactor">-</span><br />
	</div>
	<div class="ib right-pane">
		<span class="nuke-pane-header" style="display:inline;">Control:</span>
		<span id="sample-state" class="offline">NO SAMPLE</span>
		<a class="analyze" href="todo">Analyze Sample</a>
		<div class="item-icon">
			<a href="todo">insert here</a>
		</div>
		<div class="ib bord molecule"><img src="http://clipart-library.com/img/1824853.gif">
	</div>
</body>

</html>"}
