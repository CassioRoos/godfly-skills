UI -- stored XSS via seeded holder_name. Images: 01 (before), 12 (after).
Driven with the Chrome DevTools MCP at viewport 1280x900x1.

renderList built rows with innerHTML from a[holder_name]. Account ACC-9002's
holder name in the fixture is:
  Moveis <img src=x onerror="document.title='AQ-XSS'">
On load, document.title became "AQ-XSS" and the DOM contained a real <img>
element (injectedImgTags: 1). No interaction required -- opening the console
was enough.

Positive control: the payload is still in the fixture after the fix, so the
check would fail if the fix were absent. After: xssExecuted false,
injectedImgTags 0, holderCellHTML shows the payload HTML-escaped, rendered as
literal text (screenshot 12). Status: FAILED -> fixed.
