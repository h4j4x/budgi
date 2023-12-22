CREATE INDEX wallets_balances_from_date_to_date_idx ON public.wallets_balances USING btree (from_date, to_date);


