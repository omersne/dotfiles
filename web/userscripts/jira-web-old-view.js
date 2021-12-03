// ==UserScript==
// @name Jira, load old view
// @version 0.1
// @description Load Old jira view
// @author Unhappy Atlassian Customer
// @match https://*.atlassian.net/*
// @icon data&colon;image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @run-at document-start
// @grant none
// ==/UserScript==

// https://community.atlassian.com/t5/Jira-questions/How-do-I-switch-back-to-the-old-jira-interface/qaq-p/702841#M483474

(function() {
'use strict';

var loc = location.href;
if (loc.indexOf('oldIssueView') >= 0) return;
loc.indexOf("?") < 0 ? (location.href = loc+"?oldIssueView=true") : (location.href = loc+"&oldIssueView=true");
})();
