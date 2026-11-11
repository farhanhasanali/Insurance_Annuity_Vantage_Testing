-- Fictional Vantage training schema; PostgreSQL 14+
CREATE TABLE IF NOT EXISTS applications (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 app_type TEXT NOT NULL CHECK(app_type IN ('LIFE','ANNUITY')),
 applicant_name TEXT NOT NULL, -- synthetic only
 product_code TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'DRAFT' CHECK(status IN ('DRAFT','SUBMITTED','IN_REVIEW','APPROVED','REJECTED','ISSUED')),
 requested_amount NUMERIC(14,2) NOT NULL CHECK(requested_amount > 0),
 tax_qualification TEXT,
 suitability_approved BOOLEAN NOT NULL DEFAULT FALSE,
 underwriting_approved BOOLEAN NOT NULL DEFAULT FALSE,
 funding_verified BOOLEAN NOT NULL DEFAULT FALSE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS beneficiaries (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 application_id BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
 beneficiary_name TEXT NOT NULL,
 beneficiary_class TEXT NOT NULL CHECK(beneficiary_class IN ('PRIMARY','CONTINGENT')),
 share_pct NUMERIC(5,2) NOT NULL CHECK(share_pct > 0 AND share_pct <= 100)
);
CREATE TABLE IF NOT EXISTS premium_sources (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 application_id BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
 source_type TEXT NOT NULL CHECK(source_type IN ('NEW_MONEY','ROLLOVER','TRANSFER','REPLACEMENT')),
 amount NUMERIC(14,2) NOT NULL CHECK(amount >= 0),
 verified BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE TABLE IF NOT EXISTS inbound_events (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 source_system TEXT NOT NULL, external_event_id TEXT NOT NULL,
 application_id BIGINT REFERENCES applications(id),
 event_type TEXT NOT NULL, payload JSONB NOT NULL,
 received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 UNIQUE(source_system,external_event_id)
);
CREATE TABLE IF NOT EXISTS audit_events (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 application_id BIGINT NOT NULL REFERENCES applications(id),
 old_status TEXT, new_status TEXT NOT NULL,
 action TEXT NOT NULL, correlation_id TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_app_status ON applications(app_type,status);
CREATE INDEX IF NOT EXISTS ix_event_app ON inbound_events(application_id);
