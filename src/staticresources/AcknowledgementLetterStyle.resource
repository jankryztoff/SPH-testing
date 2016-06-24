@page {
	margin : .7in .5in 3in .5in;
@top-center {
    content: element(header);
}

@bottom-left {
    content: element(footer);
}
}

div.header {
padding: 10px;
position: running(header);
}

div.footer {
display: block;
padding: 5px;
position: running(footer);
}

.pagenumber:before {
content: counter(page);
}

.pagecount:before {
content: counter(pages);
}