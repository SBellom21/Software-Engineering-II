-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "postgis";

-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('TENANT', 'LANDLORD', 'ADMIN');

-- CreateEnum
CREATE TYPE "account_status" AS ENUM ('ACTIVE', 'SUSPENDED', 'BLOCKED');

-- CreateEnum
CREATE TYPE "property_type" AS ENUM ('APARTMENT', 'HOUSE');

-- CreateEnum
CREATE TYPE "property_status" AS ENUM ('AVAILABLE', 'OCCUPIED', 'DEACTIVATED');

-- CreateEnum
CREATE TYPE "rule_type" AS ENUM ('PETS', 'SMOKERS', 'MAX_OCCUPANTS', 'MIN_CONTRACT_DURATION');

-- CreateEnum
CREATE TYPE "survey_target" AS ENUM ('TENANT', 'PROPERTY');

-- CreateEnum
CREATE TYPE "like_status" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');

-- CreateEnum
CREATE TYPE "request_origin" AS ENUM ('SEARCH', 'MATCH');

-- CreateEnum
CREATE TYPE "sender_role" AS ENUM ('TENANT', 'SYSTEM');

-- CreateEnum
CREATE TYPE "request_status" AS ENUM ('ACTIVE', 'CLOSED');

-- CreateEnum
CREATE TYPE "verification_target" AS ENUM ('USER', 'PROPERTY');

-- CreateEnum
CREATE TYPE "verification_status" AS ENUM ('PENDING', 'UNMATCHED_TICKET', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "report_status" AS ENUM ('OPEN', 'RESOLVED');

-- CreateEnum
CREATE TYPE "lease_status" AS ENUM ('PENDING', 'ACTIVE', 'ENDED');

-- CreateEnum
CREATE TYPE "rating_target" AS ENUM ('TENANT', 'PROPERTY');

-- CreateEnum
CREATE TYPE "notification_type" AS ENUM ('LIKE_RECEIVED', 'MATCH', 'VERIFICATION_RESULT', 'SUSPENSION', 'LEASE_CONFIRMATION', 'NEW_MESSAGE');

-- CreateEnum
CREATE TYPE "interaction_action" AS ENUM ('LIKE', 'PASS', 'ACCEPT', 'REJECT', 'MATCH', 'REQUEST');

-- CreateTable
CREATE TABLE "users" (
    "id" BIGSERIAL NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255),
    "google_id" VARCHAR(100),
    "full_name" VARCHAR(150) NOT NULL,
    "contact" VARCHAR(100),
    "birth_date" DATE,
    "role" "user_role" NOT NULL,
    "status" "account_status" NOT NULL DEFAULT 'ACTIVE',
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "profile_score" SMALLINT,
    "mfa_secret_enc" TEXT,
    "token_version" INTEGER NOT NULL DEFAULT 1,
    "privacy_policy_version" VARCHAR(50),
    "accepted_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "anonymized_at" TIMESTAMPTZ(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "properties" (
    "id" BIGSERIAL NOT NULL,
    "landlord_id" BIGINT NOT NULL,
    "zone_id" BIGINT,
    "type" "property_type" NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "city" VARCHAR(100) NOT NULL,
    "neighborhood" VARCHAR(100) NOT NULL,
    "location" geography(Point, 4326),
    "price" DECIMAL(12,2) NOT NULL,
    "bedrooms" SMALLINT NOT NULL,
    "bathrooms" SMALLINT NOT NULL,
    "amenities" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "status" "property_status" NOT NULL DEFAULT 'AVAILABLE',
    "price_quality_score" SMALLINT,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "properties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "property_photos" (
    "id" BIGSERIAL NOT NULL,
    "property_id" BIGINT NOT NULL,
    "storage_ref" VARCHAR(500) NOT NULL,
    "position" SMALLINT NOT NULL DEFAULT 0,
    "uploaded_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "property_photos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "property_rules" (
    "id" BIGSERIAL NOT NULL,
    "property_id" BIGINT NOT NULL,
    "rule_type" "rule_type" NOT NULL,
    "value" VARCHAR(100) NOT NULL,

    CONSTRAINT "property_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "scoring_models" (
    "id" BIGSERIAL NOT NULL,
    "target" "survey_target" NOT NULL,
    "version" INTEGER NOT NULL,
    "weights" JSONB NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT false,
    "updated_by" BIGINT NOT NULL,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "scoring_models_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_weights" (
    "id" BIGSERIAL NOT NULL,
    "score_weight" DECIMAL(5,2) NOT NULL,
    "verified_bonus" DECIMAL(5,2) NOT NULL,
    "stars_weight" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "active" BOOLEAN NOT NULL DEFAULT false,
    "updated_by" BIGINT NOT NULL,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ranking_weights_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "survey_responses" (
    "id" BIGSERIAL NOT NULL,
    "target" "survey_target" NOT NULL,
    "tenant_id" BIGINT,
    "property_id" BIGINT,
    "scoring_model_id" BIGINT NOT NULL,
    "answers" JSONB NOT NULL,
    "resulting_score" SMALLINT NOT NULL,
    "completed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "survey_responses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "likes" (
    "id" BIGSERIAL NOT NULL,
    "tenant_id" BIGINT NOT NULL,
    "property_id" BIGINT NOT NULL,
    "status" "like_status" NOT NULL DEFAULT 'PENDING',
    "rules_confirmed" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decided_at" TIMESTAMPTZ(6),

    CONSTRAINT "likes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "matches" (
    "id" BIGSERIAL NOT NULL,
    "like_id" BIGINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "matches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "official_requests" (
    "id" BIGSERIAL NOT NULL,
    "tenant_id" BIGINT NOT NULL,
    "property_id" BIGINT NOT NULL,
    "match_id" BIGINT,
    "origin" "request_origin" NOT NULL,
    "sent_by" "sender_role" NOT NULL,
    "status" "request_status" NOT NULL DEFAULT 'ACTIVE',
    "rules_confirmed" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "official_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" BIGSERIAL NOT NULL,
    "official_request_id" BIGINT NOT NULL,
    "sender_id" BIGINT NOT NULL,
    "client_msg_id" UUID,
    "body" TEXT NOT NULL,
    "show_disclaimer" BOOLEAN NOT NULL DEFAULT false,
    "sent_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification_requests" (
    "id" BIGSERIAL NOT NULL,
    "ticket_code" VARCHAR(32) NOT NULL,
    "requester_id" BIGINT NOT NULL,
    "target" "verification_target" NOT NULL,
    "property_id" BIGINT,
    "status" "verification_status" NOT NULL DEFAULT 'PENDING',
    "reviewed_by" BIGINT,
    "submitted_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewed_at" TIMESTAMPTZ(6),
    "rejection_reason" TEXT,

    CONSTRAINT "verification_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification_documents" (
    "id" BIGSERIAL NOT NULL,
    "verification_request_id" BIGINT NOT NULL,
    "file_name" VARCHAR(255) NOT NULL,
    "storage_ref" VARCHAR(500) NOT NULL,
    "sha256_hash" CHAR(64) NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "uploaded_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verification_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reports" (
    "id" BIGSERIAL NOT NULL,
    "reporter_id" BIGINT NOT NULL,
    "reported_id" BIGINT NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "report_status" NOT NULL DEFAULT 'OPEN',
    "handled_by" BIGINT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolved_at" TIMESTAMPTZ(6),

    CONSTRAINT "reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leases" (
    "id" BIGSERIAL NOT NULL,
    "official_request_id" BIGINT NOT NULL,
    "tenant_id" BIGINT NOT NULL,
    "property_id" BIGINT NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE,
    "status" "lease_status" NOT NULL DEFAULT 'PENDING',
    "tenant_confirmed" BOOLEAN NOT NULL DEFAULT false,
    "landlord_confirmed" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "leases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ratings" (
    "id" BIGSERIAL NOT NULL,
    "lease_id" BIGINT NOT NULL,
    "author_id" BIGINT NOT NULL,
    "target" "rating_target" NOT NULL,
    "tenant_id" BIGINT,
    "property_id" BIGINT,
    "stars" SMALLINT NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ratings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "type" "notification_type" NOT NULL,
    "content" TEXT NOT NULL,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interaction_logs" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "property_id" BIGINT,
    "action" "interaction_action" NOT NULL,
    "result" VARCHAR(100),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "interaction_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bogota_zones" (
    "id" BIGSERIAL NOT NULL,
    "code" VARCHAR(32) NOT NULL,
    "locality_name" VARCHAR(100) NOT NULL,
    "upz_name" VARCHAR(100),
    "neighborhood_name" VARCHAR(120) NOT NULL,
    "geom" geography(MultiPolygon, 4326),
    "centroid" geography(Point, 4326),
    "reference_avg_price" DECIMAL(12,2),

    CONSTRAINT "bogota_zones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "token_hash" CHAR(64) NOT NULL,
    "family_id" UUID NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_push_tokens" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "expo_push_token" VARCHAR(255) NOT NULL,
    "platform" VARCHAR(20) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_push_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "data_deletion_requests" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "status" VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    "reason" TEXT,
    "requested_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deadline_at" TIMESTAMPTZ(6) NOT NULL,
    "completed_at" TIMESTAMPTZ(6),

    CONSTRAINT "data_deletion_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gmail_ingested_messages" (
    "id" BIGSERIAL NOT NULL,
    "gmail_message_id" VARCHAR(128) NOT NULL,
    "history_id" VARCHAR(64) NOT NULL,
    "sender_email" VARCHAR(255) NOT NULL,
    "matched_request_id" BIGINT,
    "processed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gmail_ingested_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" BIGSERIAL NOT NULL,
    "actor_admin_id" BIGINT NOT NULL,
    "action" VARCHAR(80) NOT NULL,
    "target_type" VARCHAR(50) NOT NULL,
    "target_id" BIGINT NOT NULL,
    "document_sha256" CHAR(64),
    "ip_hash" CHAR(64),
    "occurred_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "likes_tenant_id_property_id_key" ON "likes"("tenant_id", "property_id");

-- CreateIndex
CREATE UNIQUE INDEX "matches_like_id_key" ON "matches"("like_id");

-- CreateIndex
CREATE UNIQUE INDEX "official_requests_match_id_key" ON "official_requests"("match_id");

-- CreateIndex
CREATE UNIQUE INDEX "verification_requests_ticket_code_key" ON "verification_requests"("ticket_code");

-- CreateIndex
CREATE UNIQUE INDEX "ratings_lease_id_author_id_key" ON "ratings"("lease_id", "author_id");

-- CreateIndex
CREATE UNIQUE INDEX "bogota_zones_code_key" ON "bogota_zones"("code");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_token_hash_key" ON "refresh_tokens"("token_hash");

-- CreateIndex
CREATE UNIQUE INDEX "user_push_tokens_expo_push_token_key" ON "user_push_tokens"("expo_push_token");

-- CreateIndex
CREATE UNIQUE INDEX "gmail_ingested_messages_gmail_message_id_key" ON "gmail_ingested_messages"("gmail_message_id");

-- AddForeignKey
ALTER TABLE "properties" ADD CONSTRAINT "properties_landlord_id_fkey" FOREIGN KEY ("landlord_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "properties" ADD CONSTRAINT "properties_zone_id_fkey" FOREIGN KEY ("zone_id") REFERENCES "bogota_zones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "property_photos" ADD CONSTRAINT "property_photos_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "property_rules" ADD CONSTRAINT "property_rules_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "scoring_models" ADD CONSTRAINT "scoring_models_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_weights" ADD CONSTRAINT "ranking_weights_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "survey_responses" ADD CONSTRAINT "survey_responses_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "survey_responses" ADD CONSTRAINT "survey_responses_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "survey_responses" ADD CONSTRAINT "survey_responses_scoring_model_id_fkey" FOREIGN KEY ("scoring_model_id") REFERENCES "scoring_models"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "likes" ADD CONSTRAINT "likes_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "likes" ADD CONSTRAINT "likes_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "matches" ADD CONSTRAINT "matches_like_id_fkey" FOREIGN KEY ("like_id") REFERENCES "likes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "official_requests" ADD CONSTRAINT "official_requests_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "official_requests" ADD CONSTRAINT "official_requests_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "official_requests" ADD CONSTRAINT "official_requests_match_id_fkey" FOREIGN KEY ("match_id") REFERENCES "matches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_official_request_id_fkey" FOREIGN KEY ("official_request_id") REFERENCES "official_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verification_requests" ADD CONSTRAINT "verification_requests_requester_id_fkey" FOREIGN KEY ("requester_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verification_requests" ADD CONSTRAINT "verification_requests_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verification_requests" ADD CONSTRAINT "verification_requests_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verification_documents" ADD CONSTRAINT "verification_documents_verification_request_id_fkey" FOREIGN KEY ("verification_request_id") REFERENCES "verification_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reported_id_fkey" FOREIGN KEY ("reported_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_handled_by_fkey" FOREIGN KEY ("handled_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leases" ADD CONSTRAINT "leases_official_request_id_fkey" FOREIGN KEY ("official_request_id") REFERENCES "official_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leases" ADD CONSTRAINT "leases_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leases" ADD CONSTRAINT "leases_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_lease_id_fkey" FOREIGN KEY ("lease_id") REFERENCES "leases"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interaction_logs" ADD CONSTRAINT "interaction_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interaction_logs" ADD CONSTRAINT "interaction_logs_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_push_tokens" ADD CONSTRAINT "user_push_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "data_deletion_requests" ADD CONSTRAINT "data_deletion_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gmail_ingested_messages" ADD CONSTRAINT "gmail_ingested_messages_matched_request_id_fkey" FOREIGN KEY ("matched_request_id") REFERENCES "verification_requests"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_actor_admin_id_fkey" FOREIGN KEY ("actor_admin_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ============================================================================
-- RESTRICCIONES CHECK E INTEGRIDAD DE DOMINIO (Workshop 2 & ARQUITECTURA.md)
-- ============================================================================

-- Users (BR-01, BR-24, BR-29, RNF-07)
CREATE UNIQUE INDEX "uq_users_email_role_active"
  ON "users" (LOWER("email"), "role")
  WHERE "anonymized_at" IS NULL;

CREATE UNIQUE INDEX "uq_users_google_id_role_active"
  ON "users" ("google_id", "role")
  WHERE "google_id" IS NOT NULL AND "anonymized_at" IS NULL;

ALTER TABLE "users"
  ADD CONSTRAINT "chk_users_profile_score_range"
  CHECK ("profile_score" IS NULL OR ("profile_score" BETWEEN 0 AND 100));

ALTER TABLE "users"
  ADD CONSTRAINT "chk_users_admin_no_profile_score"
  CHECK ("role" != 'ADMIN' OR "profile_score" IS NULL);

-- Properties (BR-06, BR-28, BR-30, BR-45)
ALTER TABLE "properties"
  ADD CONSTRAINT "chk_properties_city_bogota"
  CHECK ("city" = 'Bogotá D.C.');

ALTER TABLE "properties"
  ADD CONSTRAINT "chk_properties_price_positive"
  CHECK ("price" > 0);

ALTER TABLE "properties"
  ADD CONSTRAINT "chk_properties_bedrooms_nonneg"
  CHECK ("bedrooms" >= 0);

ALTER TABLE "properties"
  ADD CONSTRAINT "chk_properties_bathrooms_nonneg"
  CHECK ("bathrooms" >= 0);

ALTER TABLE "properties"
  ADD CONSTRAINT "chk_properties_score_range"
  CHECK ("price_quality_score" IS NULL OR ("price_quality_score" BETWEEN 0 AND 100));

-- Scoring Models & Ranking Weights (BR-22)
CREATE UNIQUE INDEX "uq_scoring_models_active"
  ON "scoring_models" ("target")
  WHERE "active" = TRUE;

CREATE UNIQUE INDEX "uq_ranking_weights_active"
  ON "ranking_weights" ((TRUE))
  WHERE "active" = TRUE;

ALTER TABLE "ranking_weights"
  ADD CONSTRAINT "chk_ranking_weights_score_nonneg"
  CHECK ("score_weight" >= 0);

ALTER TABLE "ranking_weights"
  ADD CONSTRAINT "chk_ranking_weights_verified_nonneg"
  CHECK ("verified_bonus" >= 0);

ALTER TABLE "ranking_weights"
  ADD CONSTRAINT "chk_ranking_weights_stars_nonneg"
  CHECK ("stars_weight" >= 0);

-- Survey Responses
ALTER TABLE "survey_responses"
  ADD CONSTRAINT "chk_survey_responses_score_range"
  CHECK ("resulting_score" BETWEEN 0 AND 100);

-- Likes & Official Requests (BR-09, BR-40)
ALTER TABLE "likes"
  ADD CONSTRAINT "chk_likes_rules_confirmed"
  CHECK ("rules_confirmed" = TRUE);

ALTER TABLE "official_requests"
  ADD CONSTRAINT "chk_official_requests_rules_confirmed"
  CHECK ("rules_confirmed" = TRUE);

-- Messages (idempotencia Socket.IO)
CREATE UNIQUE INDEX "uq_messages_client_msg_id"
  ON "messages" ("official_request_id", "sender_id", "client_msg_id")
  WHERE "client_msg_id" IS NOT NULL;

-- Leases (CRC Lease / 4.1: máximo 1 arriendo ACTIVE por propiedad e inquilino)
CREATE UNIQUE INDEX "uq_leases_active_property"
  ON "leases" ("property_id")
  WHERE "status" = 'ACTIVE';

CREATE UNIQUE INDEX "uq_leases_active_tenant"
  ON "leases" ("tenant_id")
  WHERE "status" = 'ACTIVE';

-- Ratings (BR-43)
ALTER TABLE "ratings"
  ADD CONSTRAINT "chk_ratings_stars_range"
  CHECK ("stars" BETWEEN 1 AND 5);

-- Data Deletion Requests (RNF-07)
ALTER TABLE "data_deletion_requests"
  ADD CONSTRAINT "chk_data_deletion_status"
  CHECK ("status" IN ('PENDING', 'BLOCKED_BY_LEGAL_DUTY', 'COMPLETED'));

-- ============================================================================
-- ÍNDICES CRÍTICOS DE RENDIMIENTO Y POSTGIS (ARQUITECTURA.md 6.4)
-- ============================================================================

CREATE INDEX "idx_properties_search_avail"
  ON "properties" ("zone_id", "type", "price", "bedrooms", "bathrooms", "verified", "price_quality_score" DESC)
  WHERE "status" = 'AVAILABLE';

CREATE INDEX "idx_properties_amenities_gin"
  ON "properties" USING GIN ("amenities")
  WHERE "status" = 'AVAILABLE';

CREATE INDEX "idx_properties_location_gist"
  ON "properties" USING GIST ("location")
  WHERE "status" = 'AVAILABLE';

CREATE INDEX "idx_properties_zone_stats"
  ON "properties" ("zone_id", "type", "bedrooms") INCLUDE ("price")
  WHERE "status" IN ('AVAILABLE', 'OCCUPIED');

CREATE INDEX "idx_bogota_zones_geom_gist"
  ON "bogota_zones" USING GIST ("geom");

CREATE INDEX "idx_bogota_zones_centroid_gist"
  ON "bogota_zones" USING GIST ("centroid");

CREATE INDEX "idx_interaction_logs_swipe_excl"
  ON "interaction_logs" ("user_id", "property_id")
  WHERE "action" IN ('LIKE', 'PASS');

CREATE INDEX "idx_likes_inbox"
  ON "likes" ("property_id", "created_at" DESC)
  WHERE "status" = 'PENDING';

CREATE INDEX "idx_official_req_inbox"
  ON "official_requests" ("property_id", "created_at" DESC)
  WHERE "status" = 'ACTIVE';

CREATE INDEX "idx_messages_conversation"
  ON "messages" ("official_request_id", "sent_at" DESC, "id" DESC);

CREATE INDEX "idx_verif_pending"
  ON "verification_requests" ("status", "submitted_at" ASC)
  WHERE "status" = 'PENDING';

CREATE INDEX "idx_deletion_sla"
  ON "data_deletion_requests" ("status", "deadline_at" ASC)
  WHERE "status" = 'PENDING';

-- ============================================================================
-- TRIGGERS DE INMUTABILIDAD Y REGLAS DE NEGOCIO (BR-41, BR-49)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_likes_immutable_decision()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IN ('ACCEPTED', 'REJECTED') AND NEW.status IS DISTINCT FROM OLD.status THEN
    RAISE EXCEPTION 'BR-49: Una decisión sobre un like (% -> %) es inmutable.', OLD.status, NEW.status;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_likes_immutable_decision"
  BEFORE UPDATE OF "status" ON "likes"
  FOR EACH ROW
  EXECUTE FUNCTION fn_likes_immutable_decision();

CREATE OR REPLACE FUNCTION fn_ratings_lease_ended()
RETURNS TRIGGER AS $$
DECLARE
  v_lease_status "lease_status";
BEGIN
  SELECT "status" INTO v_lease_status FROM "leases" WHERE "id" = NEW."lease_id";
  IF v_lease_status IS NULL OR v_lease_status != 'ENDED' THEN
    RAISE EXCEPTION 'BR-41: Solo se puede calificar después de que el arriendo haya finalizado (ENDED).';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_ratings_lease_ended"
  BEFORE INSERT ON "ratings"
  FOR EACH ROW
  EXECUTE FUNCTION fn_ratings_lease_ended();

-- ============================================================================
-- VISTAS DE RESUMEN DE CALIFICACIONES (Workshop 2, 4.1)
-- ============================================================================

CREATE OR REPLACE VIEW "tenant_rating_summary" AS
SELECT
  u."id" AS "tenant_id",
  COALESCE(ROUND(AVG(r."stars")::numeric, 2), 5.00) AS "avg_stars",
  COUNT(r."id")::int AS "total_ratings"
FROM "users" u
LEFT JOIN "ratings" r
  ON r."tenant_id" = u."id"
 AND r."target" = 'TENANT'
WHERE u."role" = 'TENANT'
GROUP BY u."id";

CREATE OR REPLACE VIEW "property_rating_summary" AS
SELECT
  p."id" AS "property_id",
  COALESCE(ROUND(AVG(r."stars")::numeric, 2), 5.00) AS "avg_stars",
  COUNT(r."id")::int AS "total_ratings"
FROM "properties" p
LEFT JOIN "ratings" r
  ON r."property_id" = p."id"
 AND r."target" = 'PROPERTY'
GROUP BY p."id";


