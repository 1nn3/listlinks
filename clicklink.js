#!/usr/bin/env phantomjs
// clicklink.js
// Just click/load a given hyperlink and return success or failure
// See also: http://phantomjs.org/api/
"use strict";

var system = require('system');

if (system.args.length != 2) {
	system.stderr.writeLine("Usage: " + system.args[0] + " <URL>");
	phantom.exit(1);
}

var page = require("webpage").create();
page.settings.javascriptEnabled = system.env["LISTLINKS_JAVASCRIPT_ENABLED"];
page.settings.resourceTimeout = system.env["LISTLINKS_RESOURCE_TIMEOUT"] * 1000 || page.settings.resourceTimeout;
page.settings.userAgent = system.env["LISTLINKS_USER_AGENT"] || page.settings.userAgent;

page.open(system.args[1], function (status) {
	if (status !== "success") {
		system.stderr.writeLine("E: Fail to load URL: " + system.args[1]);
		phantom.exit(1);
	}
	phantom.exit(0);
});

