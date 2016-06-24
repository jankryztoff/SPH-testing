html {
	font-size: 11px;
}

table {
	width: 100%;
}

#footerWrapper {
	position: running(footer);
}

@page {
	border-left: 1px solid #000;
	border-right: 1px solid #000;
	border-bottom: 1px solid #000;
	size: A4 portrait;
	margin-top: 400px;
	margin-bottom: 70px;
	margin-left: 45px;
	margin-right: 45px;
	padding-top: 20px;
	@top-center { content: element(header); }
}

@page :first {
	margin-bottom: 370px;
	@bottom-center { content: element(footer); }
}

.pagenumber:before {
	content: counter(page);
}

.pagecount:before {
	content: counter(pages);
}

#headerWrapper {
	position: running(header);
}

#header {
	width: 100%;
	position: absolute;
	top: 55px;
	left: 5px;
}

#headerWrapper1C2 {
	font-size: 10px !important;
	padding-left: 5px;
}

#headerWrapper1C1 {
	width: 28.5mm;
}

#headerBox1 tr:first-child td {
	font-weight: bold;
}

#headerWrapper2 {
	font-size: 20px;
	font-weight: bold;
	text-align: right;
}

#headerBox1 td {
	width: 33%;
	border-bottom: 1px solid #000;
	padding: 3px;
}

#headerBox1 td:first-child {
	border-left: 1px solid #000;
}
#headerBox1 .last {
	border-right: 1px solid #000;
}

#headerWrapper3C1 {
	width: 60%;
	padding-left: 13mm;
	vertical-align: top !important;
	font-size: 9pt;
}

#headerWrapper3C2 {
	width: 40%;
	vertical-align: top !important;
}

#headerWrapper4 {
	position: absolute;
	top: 285px;
	padding-left: 10px;
	padding-right: 10px;
}

#headerWrapper4 td:first-child span:first-child {
	font-size: 13px !important;
	font-weight: bold;
}

#headerWrapper4 td:first-child i {
	font-size: 10px;
}

#headerWrapper4 td.last {
	vertical-align: bottom !important;
	text-align: right;
	font-size: 10px;
}

#summaryOfPaymentWrapper {
	border: 1px solid #000;
	padding: 3px 0;
}

#summaryOfPayment td {
	padding: 2px 5px;
}

#summaryOfPayment td:first-child {
	width: 80%;
}

#summaryOfPayment td.last {
	width: 20%;
	text-align: right;
}

td {
	vertical-align: middle;
}

.headerBox1ColumnHeader {
	width: 33%;
	font-weight: bold;
	border-top: 1px solid #000;
}

.hiddenRow {
	display: none;
}

#pageContent {
	font-size: 13px;
}

#pageContent span {
	font-weight: bold;
}

#headerWrapper5a {
	position: absolute;
	top: 330px;
	width: 681.5px;
	margin-left: -5px;
	border-top: 1px solid #000;
	border-left: 1px solid #000;
	border-right: 1px solid #000;
	padding-left: 10px;
	padding-right: 10px;
}

#headerWrapper5 td {
	font-weight: bold;
	font-size: 13px;
	border-bottom: 1px solid #000;
	padding-top: 5px;
	padding-bottom: 5px;
}

#pageContent td:first-child, #headerWrapper5 td:first-child {
	width: 50%;
}

#pageContent td.second, #headerWrapper5 td.second {
	width: 25%;
	text-align: center;
}

#pageContent td.third, #headerWrapper5 td.third {
	width: 15%;
	text-align: center;
}

#pageContent td.last, #headerWrapper5 td.last {
	width: 10%;
	text-align: right;
}

#pageContent tr {
	page-break-inside: avoid;
}

#cardType td:first-child {
	width: 70%;
}

#cardType td span {
	font-family: 'Arial Unicode MS';
}

.bottomLine {
	border-bottom: 0.5px solid #000;
}

#paymentByCheck div {
	padding-left: 20px;
}

#paymentByCard {
	padding-left: 10px;
}

#footer {
	position: absolute;
	top: 5px;
}

#footnote {
	font-size: 9.5px;
}

#footnoteBottom {
	font-size: 12px;
}

#footerWrapper1 td {
	vertical-align: top;
}

.lpad {
	padding-left: 10px;
}

hr.dashed { 
	border: 0; 
	border-bottom: 1px dashed #000;
	padding-bottom: 5px;
}

.barcode {
	margin-top: 20px !important;
}