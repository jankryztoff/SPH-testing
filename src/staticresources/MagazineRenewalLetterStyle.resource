@page {
	margin : .1in .1in .3px .1in;
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
position: footer;

}

.pagenumber:before {
content: counter(page);
}

.pagecount:before {
content: counter(pages);
}