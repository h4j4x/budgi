alter table "public"."transactions" add column "date_time" timestamp with time zone not null;

CREATE INDEX transactions_date_time_idx ON public.transactions USING btree (date_time);


