# Sales and promotion analysis: dunnhumby Carbo-Loading
Personal data analysis project that simulates periodic reporting for brand teams and corporate management. The objective of this dashboard is to present relevant metrics about sales and KPIs for 4 food categories (pasta, pasta sauce, syrups and pancake mixes) from the dunnhumby Carbo-Loading dataset, and to measure the uplift in unit sales during in-store display and flyer promotions.

## Data
Source: public dataset Carbo-Loading from dunnhumby
|Item|Values|
|---|---|
| Period | 104 weeks (2 years) |
| Categories | 4 (pasta, pasta sauce, syrups, pancake mixes) |
| Products / brands | 927 products, 131 brands |
| Transactions | about 5.2 million rows |
| Total sales | $9.130.079,89 |

Tables used: dh_transactions, dh_product_lookup, dh_causal_lookup.

The original files are not included because of their size. They can be downloaded from the [dunnhumby Source Files page](https://www.dunnhumby.com/source-files/).

## Method 
**Tools**: SQL (DB Browser for SQLite), Excel (power query, pivot tables, pivot charts, DAX measures)

1. **Import** of the 3 CSV files into DB browser for SQLite.
2. **Aggregation in SQL**: transactions (one row per item) are grouped by week, store and product; joined to category and brand (JOIN) and to promotions (LEFT JOIN). Indexes on upc, store, week speed up the joins.
3. **Promotion classification** into five states: no promo, display only, feature only, feature + display, N/A.
4. **Final table** of 11.221 rows (week, category, brand, promo type, observations, sales, units), exported to CSV.
5. **Excel**: import with power query, year column (weeks 1-52 = Year 1, weeks 53-104 = Year 2), data model, pivot tables and charts.
6. **Uplift** = average units per observation with promotion ÷ average units per observation without promotion − 1, where an observation is one product-store-week combination. The average is a DAX measure: DIVIDE(SUM(Units), SUM(Observations)).
7. **Brand view**: DAX measures (Total sales, Share of total sales, Average price, Year over year growth) and a slicer on brand connected to the brand pivots, the Corporate pivots are not connected to the slicer.

Total sales were compared at three points: the original transactions table, the SQL output and Excel. All match ($9,130,079.89), so the joins neither lost nor duplicated rows.

Query used:
```CREATE INDEX IF NOT EXISTS idx_t ON dh_transactions(upc, store, week);
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
```

[sql for dunnhumby-carbo.sql](https://github.com/user-attachments/files/34928691/sql.for.dunnhumby-carbo.sql)

## Limiti e assunzioni
Promozioni disponibili solo dalla settimana 43 alla 104, per le prime 42 settimane il file non permette di dire se un prodotto fosse in promo, quindi sono classificate N/D e escluse dal calcolo dell'uplift.
Il file delle promo contiene solo le combinazioni prodotto-negozio-settimana con almeno una promo. L'assenza di una riga è stata interpretata come "nessuna promo".

Mancano costi e margini, quindi non è possibile calcolare margine o ROI promozionale reali.
Mancano i nomi dei negozi (solo un codice numerico), quindi non c'è analisi per punto vendita. -->i negozi sono identificati tramite codice?
Mancano i budget: il confronto è fatto tra il primo e il secondo anno.
L'uplift è un confronto semplice (unità medie in promo contro unità medie senza promo). Non isola l'effetto della promo da prezzo, stagionalità e coupon. Inoltre la base senza promo considera solo le settimane con almeno una vendita, quindi tende a essere sovrastimata e l'uplift risulta prudente.
Risultati



[Es. Il tipo di promo con l'uplift maggiore è ..., con +X% di unità rispetto alle settimane senza promo.]
[Es. La categoria ... pesa il X% delle vendite totali; il brand ... ha la quota maggiore.]
[Es. Confronto tra Anno 1 e Anno 2: vendite +/- X%.]
Screenshot

[DA COMPLETARE: inserire 2-3 immagini della dashboard (vista Corporate, vista Brand, pagina Promozioni).]
