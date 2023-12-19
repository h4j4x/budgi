alter type "public"."transaction_status" rename to "transaction_status__old_version_to_be_dropped";

create type "public"."transaction_status" as enum ('pending', 'completed');

alter table "public"."transactions" alter column transaction_status type "public"."transaction_status" using transaction_status::text::"public"."transaction_status";

drop type "public"."transaction_status__old_version_to_be_dropped";


