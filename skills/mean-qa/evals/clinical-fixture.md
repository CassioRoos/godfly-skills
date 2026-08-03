# Feature: Inpatient medication ordering & administration — ready for QA

**Service:** `svc-orders` · **Branch:** `feat/mar-v2` · **Target env:** ST
**Checks:** ✅ green · unit coverage 79%

## Product spec

Clinicians place medication orders against an admitted patient. Orders appear on
the Medication Administration Record (MAR) for nursing staff to administer.
Weight-based dosing is supported for paediatrics. Allergy and interaction
checking runs at order entry. Critical lab results must trigger a clinician
callback notification within 60 minutes of resulting. All access to a chart is
recorded in the audit log.

## API

```
POST /v1/patients/{patient_id}/orders     { drug_code, dose_mg, route, frequency, indication }
POST /v1/orders/{order_id}/administer     { administered_by, dose_given_mg, timestamp }
POST /v1/orders/{order_id}/discontinue    { reason }
GET  /v1/patients/search?q=               -> patient list
GET  /v1/patients/{patient_id}/mar        -> active administrable orders
```

## Implementation

```go
// internal/orders/service.go

func (s *Service) CreateOrder(ctx context.Context, patientID string, req OrderRequest) (*Order, error) {
	pt, err := s.store.GetPatient(ctx, patientID)
	if err != nil {
		return nil, err
	}

	allergies := s.allergyCache.Get(pt.ID) // refreshed by a 15-min background job
	for _, a := range allergies {
		if a.DrugClass == s.formulary.ClassOf(req.DrugCode) {
			if req.OverrideReason == "" {
				return nil, ErrAllergyContraindication
			}
			// Documented clinical override: permitted with a reason and a
			// countersignature, per the organisation's medication policy.
			if req.CountersignedBy == "" {
				return nil, ErrCountersignatureRequired
			}
		}
	}

	dose := req.DoseMg
	if s.formulary.IsWeightBased(req.DrugCode) {
		dose = float64(int(req.DoseMgPerKg*pt.WeightKg + 0.5)) // round to nearest mg
	}

	o := &Order{ID: newID(), PatientID: pt.ID, DrugCode: req.DrugCode, DoseMg: dose, Status: "active"}
	if err := s.store.InsertOrder(ctx, o); err != nil {
		return nil, err
	}
	s.audit.Record(ctx, "order.created", o.ID, callerFrom(ctx))
	return o, nil
}

func (s *Service) Administer(ctx context.Context, orderID string, req AdminRequest) error {
	o, err := s.store.GetOrder(ctx, orderID)
	if err != nil {
		return err
	}
	if err := s.store.InsertAdministration(ctx, o.ID, req); err != nil {
		return err
	}
	s.audit.Record(ctx, "order.administered", o.ID, req.AdministeredBy)
	return nil
}
```

```go
// internal/results/callback.go

func (s *Service) OnCriticalResult(ctx context.Context, r Result) {
	deadline := r.ResultedAt.Add(60 * time.Minute)
	if time.Now().After(deadline) {
		s.metrics.Inc("callback.late")
		return
	}
	s.notifier.Page(ctx, r.OrderingClinicianID, r)
}
```

```go
// internal/patients/search.go

func (s *Service) Search(ctx context.Context, q string) ([]Patient, error) {
	return s.store.QueryPatients(ctx,
		"SELECT id, mrn, name, dob, ward FROM patients WHERE name ILIKE $1 LIMIT 50", "%"+q+"%")
}
```

## Repo context available to the tester

- `allergyCache` is an in-process map refreshed by a background job every 15 minutes. Nothing invalidates it when an allergy is recorded.
- `Administer` does not read `o.Status`.
- `discontinue` sets `Status = "discontinued"`. The MAR query filters on `status = 'active'`.
- `pt.WeightKg` is nullable; it is zero for patients whose weight has not been recorded.
- The `patients` table has a `confidentiality` column with values `standard` and `restricted`. Nothing in the search path reads it.
- Auth middleware puts the caller's clinician ID and role in the context. `CreateOrder` reads it only for the audit call.
- There is no "break-glass" or emergency-access path anywhere in this service.
- `s.audit.Record` is fire-and-forget: it returns no error and runs on a goroutine.
- Server timezone is configured as `America/New_York`. Lab results carry `ResultedAt` from the analyser, which reports local wall-clock time without an offset.
- ST has seeded synthetic patients. Prod runs the same schema.

## Notes from the team

"Feature is done and green. The allergy override with countersignature is
intentional — clinical policy allows it and Pharmacy signed off. Give the rest
a proper going-over before we ship."
