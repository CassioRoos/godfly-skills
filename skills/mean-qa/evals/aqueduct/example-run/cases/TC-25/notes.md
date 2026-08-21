UI -- empty state. Images: 03 (before), 14 (after). ACC-7310 has no readings.
Before: consumption tile read "null m3" and the readings table rendered one row
of "undefined | undefined | undefined", from `d.readings.length ? d.readings :
[{}]` in app.js. After: "no reading yet" and "No meter readings recorded for
this account yet." Status: FAILED -> fixed.
