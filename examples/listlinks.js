#!/usr/bin/env phantomjs
// listlinks.js
// Lists all hyperlinks of an URL, supports JavaScript and Frames
// See also: http://phantomjs.org/api/
"use strict";

// Um Endlosrekursion in der Frametiefe zu erkennen und abzufangen
// FIXME: Make it a constant
// const FRAME_RECURSION_MAX_DEPTH = 10;
// SyntaxError: Unexpected token 'const'
// See: https://github.com/ariya/phantomjs/issues/14521
var FRAME_RECURSION_MAX_DEPTH = 10;

function getAttributesFromElementsByTagName(tagName, attributeList) {
	var elements = window.document.getElementsByTagName(tagName);

	var values = [];
	for (var i = 0; i < elements.length; i++) {
		values.push({});

		for (var j = 0; j < attributeList.length; j++) {
			values[i][attributeList[j]] = elements[i].getAttribute(attributeList[j]) || "";
		}

		values[i]["textContent"] = elements[i].textContent || "";
	}
	return values;
}

function listLinks () {
	var a = page.evaluate(getAttributesFromElementsByTagName, "a", ["href"]);

	for (var i = 0; i < a.length; i++) {
		// FIXME: Use the class URL to get an absolut URL
		// See: https://github.com/ariya/phantomjs/issues/14349
		var href = new URL(a[i]["href"], page.url).href || a[i]["href"];
		var textContent = a[i]["textContent"].replace(/\s+/g, " ");
		system.stdout.writeLine(href + "\t" + textContent);
	}
}

function getFrames (parrents) {
	var a = page.evaluate(getAttributesFromElementsByTagName, "iframe", []);

	var frames = [];
	for (var i = 0; i < a.length; i++) {
		frames.push(parrents.concat([i])); // frame position
	}
	return frames;
}

function walkThroughFrames (frames) {
	for (var i = 0; i < frames.length; i++) {
//		system.stderr.writeLine("I: Switching to frame: " + frames[i].toString());

		if (frames[i].length > FRAME_RECURSION_MAX_DEPTH) {
			system.stderr.writeLine("W: FRAME_RECURSION_MAX_DEPTH reached!");
			continue;
		}

		page.switchToMainFrame();
		for (var j = 0; j < frames[i].length; j++) {
			page.switchToFrame(frames[i][j]);
		}

//		system.stderr.writeLine("I: frameName=" + page.frameName + " frameURL=" + page.frameUrl)

		listLinks();
		walkThroughFrames(getFrames(frames[i])); // subframes
	}
}

var system = require('system');

if (system.args.length != 2) {
	system.stderr.writeLine("Usage: " + system.args[0] + " <URL>");
	phantom.exit(1);
}

var page = require("webpage").create();
page.settings.javascriptEnabled = system.env["LISTLINKS_JAVASCRIPT_ENABLED"] || page.settings.javascriptEnabled;
page.settings.resourceTimeout = system.env["LISTLINKS_RESOURCE_TIMEOUT"] * 1000 || page.settings.resourceTimeout;
page.settings.userAgent = system.env["LISTLINKS_USER_AGENT"] || page.settings.userAgent;

page.open(system.args[1], function (status) {
	if (status !== "success") {
		system.stderr.writeLine("E: Fail to load URL: " + system.args[1]);
		phantom.exit(1);
	}

	listLinks();
	walkThroughFrames(getFrames([]));
	phantom.exit(0);
});

