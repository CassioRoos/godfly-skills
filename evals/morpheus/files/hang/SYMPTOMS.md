Service: svc-transfers, 2 replicas. After deploying the polling change, roughly 5-10 minutes
into each pod's life every GetStatus call starts failing with "context deadline exceeded".
Restarting the pod fixes it for another 5-10 minutes. The partner's own status page shows
p99 latency under 200ms the whole time. Raising http.Client Timeout from 5s to 30s did not
help; the calls just take 30s to fail instead.
