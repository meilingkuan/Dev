h1 {
	font-size: 1.8em;
	font-weight: normal;
}

h2 {
	font-size: 14px;
}

p {
	line-height: 150%;
}

a, .pbBody a, .ui-widget-content a {
	text-decoration: none;
	color: #1472CB;
}

#header_block {
	padding-top: 15px;
}

#data_logo {
	padding-right: 5px;
}

#help_block {
	float: right;
}

#help_block a {
	color: #015ba7;
	text-decoration: none;
	font-size: 91%;
}

#help_block span {
	padding-right: 5px;
}

td.count {
	text-align: right;
	font-weight: bold;
}

.blue {
	color: #1472CB;
}

.red {
	color: #CF0020;
}

.legend_element {
	padding: 10px 5px 5px 35px;
	position: relative;
}

.legend_matched, .legend_unmatched, .legend_inactive, .legend_in_sync, .legend_different, .legend_duplicate {
	height:1px;
	width:1px;
	position: absolute;
	left:0;
	top:5px;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
}

.legend_matched {
	border: 12px solid #5794D2;
	background: #5794D2;
	-webkit-print-color-adjust: exact;
}

.legend_unmatched {
	border: 12px solid #BC4C50;
	background: #BC4C50;
	-webkit-print-color-adjust: exact;
}

.legend_inactive {
	border: 12px solid #88BDFE;
	background: #88BDFE;
	-webkit-print-color-adjust: exact;
}

.legend_in_sync {
	border: 12px solid #0B4298;
	background: #0B4298;
	-webkit-print-color-adjust: exact;
}

.legend_different {
	border: 12px solid #1783B4;
	background: #1783B4;
	-webkit-print-color-adjust: exact;
}

img.message_icon {
	vertical-align: middle;
	padding-right: 5px;
}

.inner_content {
	padding: 0px 7px;
}

#time_estimate {
	float: right;
	padding: 10px;
	border: 1px solid #D9D9D9;
	-webkit-border-radius: 7px;
	-moz-border-radius: 7px;
	border-radius: 7px;
	font-size: 14px;
	font-weight: bold;
}

.setup_checkbox {
	padding: 5px 5px 5px 15px;
}

#setup_email {
	padding-left: 22px;
}

#start_button {
	padding-left: 22px;
}

#start_button input {
	margin-right: 10px;
	padding: 4px 8px;
}

#breadcrumbs {
	color: #535353;
	padding-bottom: 20px;
}

#record_table {
	border: 1px solid #AED3FF;
	background: #F0F7FD;
	width: 95%;
	spacing: 10px;
	padding: 10px 20px;
	-webkit-border-radius: 7px;
	-moz-border-radius: 7px;
	border-radius: 7px;
}

#record_table table {
	width: 100%;
}

#record_table th {
	text-align: center;
	padding-bottom: 10px;
	font-weight: normal;
}

#record_table td {
	width: 15%;
}

.assessment_table {
	margin: 1em 0 2em 0;
}

.assessment_table, .assessment_table th, .assessment_table td {
	border: 1px solid #D9DCDF;
	border-collapse: collapse;
}

.assessment_table th, .assessment_table td {
	padding: 5px 50px 5px 5px;
}

.assessment_table td {
	background: white;
}

.assessment_table th {
	background: #EFF0F0;
}

#explain {
	width: 95%;
}

#explain_left {
	float: left;
	width: 45%;
}

#explain_right {
	float: right;
	width: 45%;
}

#results_iframe {
	border: none;
}

.blank_highlight {
	color: #CF0020;
}

.different_highlight {
	color: #15A648;
}

.ui-tabs, .ui-widget input {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
}

.ui-tabs {
	border: none;
}

.ui-tabs-nav {
	background: white;
	border: none;
	border-bottom: 1px solid #BCBCBC;
	-webkit-border-radius: 0;
	-moz-border-radius: 0;
	border-radius: 0;
}

.ui-tabs .ui-tabs-nav li.ui-tabs-active {
	margin-bottom: -3px;
	padding-bottom: 3px;
}

.ui-tabs .ui-tabs-nav li {
	margin-right: .3em;
	font-weight: bold;
}

.ui-tabs .ui-tabs-nav li a {
	outline:none;
}

#setup, #assessments, #summary, #accounts, #contacts, #leads, #unmatched {
	padding: 1em 0em;
}


#maintabs .ui-tabs-nav {
	border-bottom: 3px solid #1F76C4;
}

.jqplot-target {
	height: 250px;
	width: 250px;
	position: relative;
}

.jqplot-data-label {
	color: white;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
}

#print_link {
	float: right;
}

.marketing_sidebar {
	float: left;
	width: 28%;
	margin: 32px 5px 5px 30px;
}

.unmatched_sidebar {
	float: left;
	width: 35%;
	margin: 25px 5px 5px 30px;
}

.field_table_count_header {
	position: absolute;
	right: 2px;
}

.field_table_wrapper {
	float: left;
	position: relative;
}

.summary_text {
	padding-top: 10px;
}

.clear {
	clear: both;
	page-break-after: always;
}

.match_rate_sidebar {
	float: right;
	width: 230px;
	border: 1px solid #98ECB1;
	background: #EDFFF1;
	padding: 10px;
	-webkit-border-radius: 7px;
	-moz-border-radius: 7px;
	border-radius: 7px;
	margin-top: 12px;
}

#unmatched .match_rate_sidebar {
	margin-top: 25px;
}

.match_rate_sidebar p {
	margin-top: 3px;
	margin-bottom: 0px;
}

#did_you_know_icon {
	padding-right: 7px;
	vertical-align: middle;
}

@media print {
	.assessment_table th, .assessment_table td {
		padding: 5px 40px 5px 5px;
	}
	div.bPageFooter div {
		display: none;
	}
}
