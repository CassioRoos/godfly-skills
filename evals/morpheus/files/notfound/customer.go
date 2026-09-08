package customer

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
)

var ErrNotFound = errors.New("customer not found")

type Customer struct {
	ID    string
	Email string
}

type Repo struct{ db *sql.DB }

// Get wraps every driver error with the customer id so logs are searchable.
func (r *Repo) Get(ctx context.Context, id string) (*Customer, error) {
	var c Customer
	err := r.db.QueryRowContext(ctx, `SELECT id, email FROM customers WHERE id = $1`, id).Scan(&c.ID, &c.Email)
	if err != nil {
		return nil, fmt.Errorf("customer %s: %w", id, err)
	}
	return &c, nil
}

type Service struct{ repo *Repo }

// GetCustomer maps a missing row to ErrNotFound so the HTTP layer returns 404
// instead of 500. Before this change the comparison was `err == sql.ErrNoRows`,
// which never matched the wrapped error from Repo.Get.
func (s *Service) GetCustomer(ctx context.Context, id string) (*Customer, error) {
	c, err := s.repo.Get(ctx, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return c, nil
}
