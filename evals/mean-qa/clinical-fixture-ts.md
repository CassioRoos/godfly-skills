# Feature: Inpatient medication ordering & administration — ready for QA

**Repo:** `medication-orders` · **Branch:** `feat/mar-v2` · **Target env:** staging
**Stack:** Node 20 / TypeScript / Express / Postgres · **Checks:** ✅ green · coverage 79%

## Product spec

Clinicians place medication orders against an admitted patient. Orders appear on
the Medication Administration Record (MAR) for nursing staff to administer.
Weight-based dosing is supported for paediatrics. Allergy and interaction
checking runs at order entry. Critical lab results must trigger a clinician
callback notification within 60 minutes of resulting. All access to a chart is
recorded in the audit log.

## API

```
POST /v1/patients/:patientId/orders     { drugCode, doseMg, route, frequency, indication }
POST /v1/orders/:orderId/administer     { administeredBy, doseGivenMg, timestamp }
POST /v1/orders/:orderId/discontinue    { reason }
GET  /v1/patients/search?q=             -> patient list
GET  /v1/patients/:patientId/mar        -> active administrable orders
```

## Implementation

```ts
// src/orders/service.ts

export class OrderService {
  async createOrder(ctx: Ctx, patientId: string, req: OrderRequest): Promise<Order> {
    const pt = await this.store.getPatient(ctx, patientId);

    const allergies = this.allergyCache.get(pt.id); // refreshed by a 15-min timer
    for (const a of allergies) {
      if (a.drugClass === this.formulary.classOf(req.drugCode)) {
        if (!req.overrideReason) {
          throw new AllergyContraindicationError();
        }
        // Documented clinical override: permitted with a reason and a
        // countersignature, per the organisation's medication policy.
        if (!req.countersignedBy) {
          throw new CountersignatureRequiredError();
        }
      }
    }

    let dose = req.doseMg;
    if (this.formulary.isWeightBased(req.drugCode)) {
      dose = Math.round(req.doseMgPerKg * pt.weightKg); // round to nearest mg
    }

    const order: Order = {
      id: newId(), patientId: pt.id, drugCode: req.drugCode, doseMg: dose, status: 'active',
    };
    await this.store.insertOrder(ctx, order);
    this.audit.record(ctx, 'order.created', order.id, callerFrom(ctx));
    return order;
  }

  async administer(ctx: Ctx, orderId: string, req: AdminRequest): Promise<void> {
    const order = await this.store.getOrder(ctx, orderId);
    await this.store.insertAdministration(ctx, order.id, req);
    this.audit.record(ctx, 'order.administered', order.id, req.administeredBy);
  }
}
```

```ts
// src/results/callback.ts

export async function onCriticalResult(ctx: Ctx, r: Result): Promise<void> {
  const deadline = new Date(r.resultedAt).getTime() + 60 * 60 * 1000;
  if (Date.now() > deadline) {
    metrics.inc('callback.late');
    return;
  }
  await notifier.page(ctx, r.orderingClinicianId, r);
}
```

```ts
// src/patients/search.ts

export async function search(ctx: Ctx, q: string): Promise<Patient[]> {
  return db.query(
    'SELECT id, mrn, name, dob, ward FROM patients WHERE name ILIKE $1 LIMIT 50',
    [`%${q}%`],
  );
}
```

## Repo context available to the tester

- `allergyCache` is an in-process `Map` refreshed by a `setInterval` every 15 minutes. Nothing invalidates it when an allergy is recorded.
- `administer` does not read `order.status`.
- `discontinue` sets `status = 'discontinued'`. The MAR query filters on `status = 'active'`.
- `patient.weightKg` is `number | undefined`; it is absent for patients whose weight has not been recorded.
- The `patients` table has a `confidentiality` column with values `standard` and `restricted`. Nothing in the search path reads it.
- Auth middleware puts the caller's clinician id and role on `ctx`. `createOrder` reads it only for the audit call.
- `formulary.classOf()` and `formulary.isWeightBased()` are synchronous lookups against a dictionary loaded at boot from an external service. Neither has an error path.
- There is no "break-glass" or emergency-access route anywhere in this service.
- `audit.record()` returns `void` and performs its write in a floating promise.
- Server `TZ` is `America/New_York`. Lab results carry `resultedAt` as a string from the analyser, formatted `YYYY-MM-DD HH:mm:ss` with no offset or zone.
- Staging has seeded synthetic patients. Production runs the same schema.

## Notes from the team

"Feature is done and green. The allergy override with countersignature is
intentional — clinical policy allows it and Pharmacy signed off. Give the rest
a proper going-over before we ship."
