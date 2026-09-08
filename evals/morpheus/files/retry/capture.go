package payments

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"
)

// TODO(legacy): move base URL to config. Pre-existing, not part of this change.
const pspBaseURL = "https://psp.example.com/v1"

type CaptureRequest struct {
	OrderID  string  `json:"order_id"`
	Amount   float64 `json:"amount"`
	Currency string  `json:"currency"`
}

type CaptureResult struct {
	ChargeID string `json:"charge_id"`
	Status   string `json:"status"`
}

type Capturer struct {
	psp_client *http.Client
	maxRetries int
}

func NewCapturer(c *http.Client) *Capturer {
	return &Capturer{psp_client: c, maxRetries: 3}
}

// Capture sends the capture to the PSP. PSP 5xx responses are treated as
// transient and retried with a short backoff.
func (c *Capturer) Capture(ctx context.Context, req CaptureRequest, traceID string) (*CaptureResult, error) {
	var lastErr error
	for attempt := 0; attempt < c.maxRetries; attempt++ {
		body, _ := json.Marshal(req)
		httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, pspBaseURL+"/captures", bytes.NewReader(body))
		if err != nil {
			return nil, err
		}
		httpReq.Header.Set("Content-Type", "application/json")

		resp, err := c.psp_client.Do(httpReq)
		if err != nil {
			lastErr = err
			time.Sleep(time.Duration(attempt+1) * 200 * time.Millisecond)
			continue
		}
		defer resp.Body.Close()

		if resp.StatusCode >= 500 {
			lastErr = fmt.Errorf("psp 5xx: %d", resp.StatusCode)
			time.Sleep(time.Duration(attempt+1) * 200 * time.Millisecond)
			continue
		}
		if resp.StatusCode >= 400 {
			return nil, fmt.Errorf("psp rejected capture: %d", resp.StatusCode)
		}

		var out CaptureResult
		if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
			return nil, err
		}
		return &out, nil
	}
	return nil, errors.Join(errors.New("capture failed after retries"), lastErr)
}
