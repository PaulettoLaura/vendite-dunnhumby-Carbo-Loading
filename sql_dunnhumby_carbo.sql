CREATE INDEX IF NOT EXISTS idx_t ON dh_transactions(upc, store, week);
CREATE INDEX IF NOT EXISTS idx_c ON dh_causal_lookup(upc, store, week);
CREATE TABLE vendite_promo AS
WITH base AS (
     SELECT week,store,upc,
	        SUM(dollar_sales) AS vendite,
			SUM(units) AS unita
	 FROM dh_transactions
	 GROUP BY week, store, upc
)
SELECT
  b.week,
  p.commodity AS categoria, 
  p.brand,
CASE
  WHEN b.week < 43 THEN 'N/D'
  WHEN c.upc IS NULL THEN 'nessuna' 
  WHEN c.feature_desc <> 'Not on Feature' AND c.display_desc <> 'Not on Display' THEN 'volantino+display'
  WHEN c.feature_desc <> 'Not on Feature' THEN 'solo volantino'
  WHEN c.display_desc <> 'Not on Display' THEN 'solo display'
  ELSE 'nessuna'
 END AS tipo_promo,
 COUNT (*) AS osservazioni,
 SUM (b.vendite) AS vendite,
 SUM (b.unita) AS unita
FROM base b
JOIN dh_product_lookup p ON p.upc = b.upc
LEFT JOIN dh_causal_lookup c
  ON c.upc = b.upc AND c.store = b.store AND c.week = b.week 
GROUP BY 1,2,3,4;
			