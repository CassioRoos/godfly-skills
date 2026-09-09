package partner

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"time"
)

// Client talks to the partner's status endpoint. One instance per service.
type Client struct {
	http    *http.Client
	baseURL string
}

func NewClient(baseURL string) *Client {
	tr := &http.Transport{
		DialContext: (&net.Dialer{
			Timeout:   2 * time.Second,
			KeepAlive: 30 * time.Second,
		}).DialContext,
		MaxIdleConns:        20,
		MaxIdleConnsPerHost: 10,
		MaxConnsPerHost:     10,
		IdleConnTimeout:     90 * time.Second,
	}
	return &Client{
		http:    &http.Client{Transport: tr, Timeout: 5 * time.Second},
		baseURL: baseURL,
	}
}

type Status struct {
	ID    string `json:"id"`
	State string `json:"state"`
}

// GetStatus fetches the partner-side status for a transfer. The partner returns
// 404 for transfers it has not ingested yet, which is common in the first few
// seconds after creation; callers poll until they get a 200.
func (c *Client) GetStatus(ctx context.Context, transferID string) (*Status, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+"/transfers/"+transferID, nil)
	if err != nil {
		return nil, err
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("partner status: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("partner status: unexpected %d", resp.StatusCode)
	}
	defer resp.Body.Close()

	var s Status
	if err := json.NewDecoder(resp.Body).Decode(&s); err != nil {
		return nil, fmt.Errorf("partner status: decode: %w", err)
	}
	return &s, nil
}
