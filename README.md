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
| Total sales | $9,130,079.89 |

Tables used: dh_transactions, dh_product_lookup, dh_causal_lookup.

The original files are not included because of their size. They can be downloaded from the [dunnhumby Source Files page](https://www.dunnhumby.com/source-files/).

## Method 

SQL
Importazione dei tre file CSV in DB browser for SQLite.
Aggregazione in SQL: le transazioni (una riga per articolo acquistato) sono raggruppate per settimana, negozio e prodotto; poi collegate a categoria e brand (JOIN) e alle promozioni (LEFT JOIN). Sono stati creati indici su upc, store, week per velocizzare le query.
Classificazione delle promo in cinque stati: solo volantino, solo display, volantino + display, nessuna, N/D.
Tabella finale di 11.221 righe (settimana, categoria, brand, tipo promo, osservazioni, vendite, unità), esportata in CSV.
Query utilizzata:
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
# Excel
Excel: importazione con Power Query, colonna anno (settimane 1-52 = Anno 1, 53-104 = Anno 2), Modello dati, pivot e dashboard.
Il totale delle vendite è stato confrontato in SQL ed Excel, il valore coincide (9.130.079,89 $), quindi i JOIN non hanno perso né duplicato righe.

Limiti e assunzioni
Promozioni disponibili solo dalla settimana 43 alla 104, per le prime 42 settimane il file non permette di dire se un prodotto fosse in promo, quindi sono classificate N/D e escluse dal calcolo dell'uplift.
Il file delle promo contiene solo le combinazioni prodotto-negozio-settimana con almeno una promo. L'assenza di una riga è stata interpretata come "nessuna promo".

Mancano costi e margini, quindi non è possibile calcolare margine o ROI promozionale reali.
Mancano i nomi dei negozi (solo un codice numerico), quindi non c'è analisi per punto vendita. -->i negozi sono identificati tramite codice?
Mancano i budget: il confronto è fatto tra il primo e il secondo anno.
L'uplift è un confronto semplice (unità medie in promo contro unità medie senza promo). Non isola l'effetto della promo da prezzo, stagionalità e coupon. Inoltre la base senza promo considera solo le settimane con almeno una vendita, quindi tende a essere sovrastimata e l'uplift risulta prudente.
Risultati

[DA COMPLETARE quando le pivot sono pronte: 3-4 conclusioni, ognuna con un numero.]

[Es. Il tipo di promo con l'uplift maggiore è ..., con +X% di unità rispetto alle settimane senza promo.]
[Es. La categoria ... pesa il X% delle vendite totali; il brand ... ha la quota maggiore.]
[Es. Confronto tra Anno 1 e Anno 2: vendite +/- X%.]
Screenshot

[DA COMPLETARE: inserire 2-3 immagini della dashboard (vista Corporate, vista Brand, pagina Promozioni).]
