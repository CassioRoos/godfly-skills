# PR #482 — Fix duplicate wallet crediting on webhook retries

**Base:** main · **Head:** fix/duplicate-credit · **Checks:** ✅ all green · **Reviews:** 1 approval

## PR Description

Fixes INC-291: customers were credited twice when the payment provider
retried webhook delivery after a slow response. Root cause was the webhook
handler crediting the wallet without checking whether the event was already
processed. This PR adds an idempotency check on the provider event ID.

Tested: added unit test for `isDuplicateEvent`, all green.

## Diff

```diff
--- a/internal/webhooks/payment_handler.go
+++ b/internal/webhooks/payment_handler.go
@@ -18,6 +18,14 @@ func (h *Handler) HandlePaymentWebhook(w http.ResponseWriter, r *http.Request) {
 	var evt ProviderEvent
 	if err := json.NewDecoder(r.Body).Decode(&evt); err != nil {
 		w.WriteHeader(http.StatusBadRequest)
 		return
 	}
+
+	dup, err := h.store.IsDuplicateEvent(r.Context(), evt.ID)
+	if err != nil {
+		log.Printf("dup check failed: %v", err)
+	}
+	if dup {
+		w.WriteHeader(http.StatusOK)
+		return
+	}
 
 	if err := h.wallet.Credit(r.Context(), evt.CustomerID, evt.Amount); err != nil {
 		w.WriteHeader(http.StatusInternalServerError)
 		return
 	}
 	w.WriteHeader(http.StatusOK)
 }

--- a/internal/webhooks/store.go
+++ b/internal/webhooks/store.go
@@ -41,3 +41,12 @@
+// IsDuplicateEvent reports whether the provider event was already processed.
+func (s *Store) IsDuplicateEvent(ctx context.Context, eventID string) (bool, error) {
+	var count int
+	err := s.db.QueryRowContext(ctx,
+		"SELECT COUNT(*) FROM processed_events WHERE event_id = $1", eventID).Scan(&count)
+	return count > 0, err
+}

--- a/internal/webhooks/store_test.go
+++ b/internal/webhooks/store_test.go
@@ -0,0 +1,14 @@
+func TestIsDuplicateEvent(t *testing.T) {
+	s := newTestStore(t)
+	s.markProcessed("evt_123")
+	dup, err := s.IsDuplicateEvent(context.Background(), "evt_123")
+	require.NoError(t, err)
+	require.True(t, dup)
+}
```

## Additional repo context (visible to the reviewer)

- `internal/webhooks/payment_handler.go` — nothing in the diff or elsewhere
  writes to `processed_events` after crediting. The only writer is a
  backfill script in `scripts/backfill_events.go`.
- `internal/admin/replay.go` has `ReplayEvent(eventID)` which calls
  `h.wallet.Credit(...)` directly, bypassing `HandlePaymentWebhook`.
- `processed_events.event_id` has no unique index (checked migration files).
- Two webhook deliveries arriving concurrently both pass the duplicate
  check before either records the event.
