create type "public"."transaction_status" as enum ('pendent', 'completed');

alter type "public"."transaction_type" rename to "transaction_type__old_version_to_be_dropped";

create type "public"."transaction_type" as enum ('income', 'incomeTransfer', 'expense', 'expenseTransfer', 'walletTransfer');

alter table "public"."transactions" alter column transaction_type type "public"."transaction_type" using transaction_type::text::"public"."transaction_type";

drop type "public"."transaction_type__old_version_to_be_dropped";

alter table "public"."transactions" add column "transaction_status" transaction_status not null;

CREATE INDEX transactions_transaction_status_idx ON public.transactions USING btree (transaction_status);


