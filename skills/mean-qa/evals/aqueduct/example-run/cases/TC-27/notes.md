UI -- console health. app.js:20 called window.Chartlet.render, but no script
tag loads Chartlet, so every page load threw "Uncaught TypeError: Cannot read
properties of undefined (reading 'render')" and the sparkline div stayed 0px
high and empty. A clean-looking screen over a dirty console.
After: the call is guarded; the only console entry left is a browser-initiated
/favicon.ico 404, which the app does not serve and which is not a defect.
Evidence: console-list-view.txt, console-network-ui-run.txt.
Status: FAILED -> fixed.
