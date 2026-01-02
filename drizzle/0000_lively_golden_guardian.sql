CREATE TYPE "public"."confidence" AS ENUM('high', 'low');--> statement-breakpoint
CREATE TABLE "bom_lines" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid,
	"component_id" uuid,
	"required_specs" jsonb NOT NULL,
	"qty_needed" integer NOT NULL,
	"designators" text,
	"notes" text,
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp
);
--> statement-breakpoint
CREATE TABLE "component_types" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"description" text,
	"spec_schema" jsonb,
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp,
	CONSTRAINT "component_types_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "components" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"type_id" uuid,
	"name" varchar NOT NULL,
	"manufacturer" varchar,
	"part_number" varchar,
	"manufacturer_part_number" text,
	"inventory" integer DEFAULT 0 NOT NULL,
	"reorder_threshold" integer,
	"location_id" uuid,
	"location_detail" text,
	"specs" jsonb DEFAULT '{}' NOT NULL,
	"notes" text,
	"datasheet_url" varchar,
	"identity_confidence" "confidence" DEFAULT 'high',
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp,
	CONSTRAINT "components_id_unique" UNIQUE("id"),
	CONSTRAINT "components_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "locations" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"description" text,
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp,
	CONSTRAINT "locations_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "projects" (
	"id" uuid PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"description" text,
	"parts_lists" jsonb,
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp,
	CONSTRAINT "projects_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "purchases" (
	"id" uuid PRIMARY KEY NOT NULL,
	"component_id" uuid,
	"supplier_id" serial NOT NULL,
	"quantity" integer NOT NULL,
	"unit_price" numeric(10, 4),
	"currency" text DEFAULT 'usd',
	"order_reference" text,
	"purchased_at" date NOT NULL,
	"notes" text,
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp
);
--> statement-breakpoint
CREATE TABLE "supplier_part_numbers" (
	"id" serial PRIMARY KEY NOT NULL,
	"component_id" uuid,
	"supplier_id" serial NOT NULL,
	"supplier_part_number" varchar NOT NULL,
	"supplier_description" text,
	"last_seen_at" timestamp,
	CONSTRAINT "supplier_part_numbers_supplier_part_number_unique" UNIQUE("supplier_part_number")
);
--> statement-breakpoint
CREATE TABLE "suppliers" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"url" varchar NOT NULL,
	"city" varchar NOT NULL,
	"state" varchar NOT NULL,
	"zip" varchar,
	"customer_service_email" varchar,
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp,
	CONSTRAINT "suppliers_name_unique" UNIQUE("name")
);
--> statement-breakpoint
ALTER TABLE "bom_lines" ADD CONSTRAINT "bom_lines_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "bom_lines" ADD CONSTRAINT "bom_lines_component_id_components_id_fk" FOREIGN KEY ("component_id") REFERENCES "public"."components"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "components" ADD CONSTRAINT "components_type_id_component_types_id_fk" FOREIGN KEY ("type_id") REFERENCES "public"."component_types"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "components" ADD CONSTRAINT "components_location_id_locations_id_fk" FOREIGN KEY ("location_id") REFERENCES "public"."locations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchases" ADD CONSTRAINT "purchases_component_id_components_id_fk" FOREIGN KEY ("component_id") REFERENCES "public"."components"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchases" ADD CONSTRAINT "purchases_supplier_id_suppliers_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_part_numbers" ADD CONSTRAINT "supplier_part_numbers_supplier_id_suppliers_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_components_specs" ON "components" USING GIN ("specs");--> statement-breakpoint
CREATE INDEX "idx_components_type" ON "components" USING btree ("id");--> statement-breakpoint
CREATE INDEX "idx_components_quantity" ON "components" USING btree ("inventory") WHERE "components"."inventory" <= "components"."reorder_threshold";--> statement-breakpoint
CREATE INDEX "idx_components_mpn" ON "components" USING btree ("manufacturer_part_number");--> statement-breakpoint
CREATE INDEX "idx_supplier_pnlookup" ON "supplier_part_numbers" USING btree ("supplier_id","supplier_part_number");