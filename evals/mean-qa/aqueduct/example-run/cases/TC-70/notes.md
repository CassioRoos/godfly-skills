UI case. Single click on the "Issue shutoff notice" button in the Actions bar of
/account/ACC-1188. No confirmation dialog, no stage selector: app.js sends
{stage:"final"} unconditionally. Images: 04-detail-acc1188-healthy.png (before),
09-shutoff-after-one-click.png (after). Reproduced 2/2 (see also TC-10 at the API).
