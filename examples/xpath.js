#!/usr/bin/env phantomjs
// see also: https://phantomjs.org/api/
//           https://developer.mozilla.org/docs/Web/JavaScript
// usage: phantomjs xpath.js <url> <xpath expression>

"use strict";

function xpath(xpathExpression) {
	var xpathResult = window.document.evaluate(
		xpathExpression,
		document,
		null,
		XPathResult.FIRST_ORDERED_NODE_TYPE,
		null);
	return xpathResult.singleNodeValue.textContent || "";
}

var system = require('system');

if (system.args.length != 3) {
	system.stderr.writeLine("Usage: " + system.args[0] + " <url> <xpath expression>");
	phantom.exit(1);
}

var page = require("webpage").create();

page.open(system.args[1], function (status) {
	if (status !== "success") {
		system.stderr.writeLine("E: Fail to load URL: " + system.args[1]);
		phantom.exit(1);
	}

	system.stdout.writeLine(page.evaluate(xpath, system.args[2]));

	phantom.exit(0);
});

