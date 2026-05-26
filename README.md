# Supply Chain Data Warehouse & Dashboard
### E-Commerce Logistics Analytics · Snowflake · SQL · Power BI

<img width="1542" height="875" alt="image" src="https://github.com/user-attachments/assets/fba1ba8b-1a57-4250-a388-0f18b63f0773" />

<img width="1545" height="885" alt="image" src="https://github.com/user-attachments/assets/f024ad88-b4bc-43c0-bc94-655dd987217d" />

## 🇬🇧 English

### Project Summary

This project implements a full data engineering pipeline for a Brazilian e-commerce supply chain dataset (87K orders, 2016–2018). Raw transactional data is modelled through a **Medallion Architecture** in Snowflake - Bronze (raw) → Silver (cleaned, enriched, relational) → Gold (analytics-ready views) - and delivered as an interactive Power BI dashboard.

The scope encompasses access control design, schema modelling, multi-step SQL transformation, automated data quality procedures with audit logging, and nine analytical views consumed directly by Power BI.


### Tech Stack

| Layer | Tool | Role |
|---|---|---|
| Storage & Compute | Snowflake | Data warehouse, transformations, procedures |
| Transformation | SQL | DDL, DML, access control, pipeline automation |
| Visualisation | Power BI | Dashboard, DAX measures |
| Version Control | GitHub | Source of truth for all SQL objects |

### Architecture

**Bronze** - source tables loaded via Snowflake UI, preserved without modification. - 5 raw tables (source copy).
**Silver** - column standardisation, type narrowing, enrichment via JOIN with ORDER_ITEMS, five calculated fields, primary and foreign key constraints, deduplication.  - 3 modelled tables + AUDIT_LOG.
**Gold** - dimensional model (DIM_CUSTOMERS, DIM_PRODUCTS, FACT_ORDERS) plus nine purpose-built analytical views feeding Power BI directly. - 2 DIM views, 1 FACT view, 9 analytical views.


### Access Control

Role-based access follows the principle of least privilege across three roles:

| Role | Scope |
|---|---|
| `ENGINEER_ROLE` | Full read/write - BRONZE, SILVER, GOLD |
| `ANALYST_ROLE` | Read-only - GOLD tables and views |
| `VIEWER_ROLE` | Read-only - GOLD views only |



### Silver Layer - Transformations

| Operation | Detail |
|---|---|
| Column renames | 10 columns standardised across CUSTOMERS, ORDERS, PRODUCTS |
| Type changes | `PRICE`, `SHIPPING_CHARGES` → `NUMBER(10,2)`; `SELLER_ID` → `VARCHAR(50)` |
| JOIN enrichment | `SELLER_ID`, `PRICE`, `SHIPPING_CHARGES`, `PRODUCT_ID` pulled from BRONZE.ORDER_ITEMS |
| Calculated fields | `TOTAL_ORDER_VALUE`, `ORDER_PERFORMANCE_DAYS`, `ESTIMATED_ORDER_PERFORMANCE_DAYS`, `DELIVERY_PERFORMANCE` |
| NULL handling | `DELIVERY_PERFORMANCE` returns `unknown` when approval or delivery date is missing |
| Constraints | Primary keys on all three tables; foreign keys ORDERS → CUSTOMERS, ORDERS → PRODUCTS |

### Data Quality Pipeline

Three stored procedures run in sequence, each writing to `SILVER.AUDIT_LOG`:

```
REFRESH_GOLD()
    
    ├── VALIDATE_DATA()          checks NULL keys, invalid date sequences,
                                negative monetary values
    
       [aborts pipeline if validation fails]
    
    └── CLEAN_SILVER_DATA()      removes NULL-key records, deduplicates
                                 ORDERS, CUSTOMERS, PRODUCTS via ROW_NUMBER()
```

Every execution - pass or abort - is recorded in AUDIT_LOG with procedure name, status, rows processed, and a descriptive message.


### Dashboard — Key Metrics

| Metric | Value |
|---|---|
| Total Orders | 87,000 |
| Total Revenue | 33.79M $ |
| Avg Order Value | 386.53 $ |
| Delayed | 6.41% |
| On Time | 1.30% |
| Early | 92.29% |


### Analysis

#### Delivery estimate strategy
92.29% of orders arrive before the estimated delivery date; only 1.30% arrive exactly on time. The near-complete absence of "on time" outcomes indicates that ESTIMATED_DELIVERY dates are systematically inflated - a deliberate *under-promise, over-deliver* strategy that maximises customer satisfaction scores at the expense of masking true operational efficiency.

#### Geographic concentration of delays
The Top 10 most delayed cities - Santa Cruz De Goias, Adhemar De Barros, Arace - are small, remote municipalities with average delivery times exceeding 100 days. Order volume is densely concentrated in south-eastern Brazil, where infrastructure is strongest. The data reveals a structural two-tier delivery experience: urban customers receive fast, early deliveries; rural customers face systemic delays driven by last-mile logistics gaps.

#### Category-level delay drivers
*Toys* rank as the worst-performing product category by delayed order volume. This aligns with predictable seasonal demand spikes (Christmas, school holidays) that saturate carrier capacity. The pattern suggests a cyclical, foreseeable problem - addressable through seasonal capacity planning rather than permanent infrastructure investment.

#### Delay rate vs. revenue: a decoupling
Monthly delay rates peak independently of monthly revenue peaks. High order volume is not the primary driver of delays - operational bottlenecks (carrier availability, warehouse throughput, product handling) appear to cause delay spikes regardless of overall volume.

#### Shipping cost as a delay signal
Delayed orders carry a consistently higher median shipping charge (~38 BRL) compared to early (~36 BRL) and on-time (~34 BRL) deliveries. This pattern may reflect two compounding effects: heavier or bulkier products are inherently harder to route efficiently, and expedited shipping is applied reactively to partially recover delayed shipments — generating cost without resolving the underlying routing problem.

### How to Run

> **Note:** `SUPPLY_CHAIN_DB`, all schemas, and Bronze tables were provisioned via the Snowflake UI. Their DDL is included in this README for reproducibility.

```
1. sql/00_Preparation/      provision roles, users, grants
2. sql/01_silver/           build and populate Silver (run 01 → 07 in order)
3. sql/02_gold/             deploy base views, then analytical views
4. sql/03_procedures/       deploy stored procedures
5. CALL SILVER.REFRESH_GOLD()   execute full pipeline
6. Power BI                 connect to Snowflake, point visuals at Gold views
```
### Database used in project: https://www.kaggle.com/datasets/bytadit/ecommerce-order-dataset


## 🇵🇱 Wersja polska

### Streszczenie projektu

Projekt implementuje kompletny pipeline inżynierii danych dla brazylijskiego zbioru danych e-commerce łańcucha dostaw (87 tys. zamówień, 2016–2018). Surowe dane transakcyjne są modelowane przez **architekturę Medallion** w Snowflake - Bronze (surowe) → Silver (oczyszczone, wzbogacone, relacyjne) → Gold (widoki gotowe do analizy) - i dostarczane jako interaktywny dashboard Power BI.

Zakres obejmuje projektowanie kontroli dostępu, modelowanie schematu, wieloetapową transformację SQL, automatyczne procedury jakości danych z logowaniem audytowym oraz dziewięć widoków analitycznych konsumowanych bezpośrednio przez Power BI.

### Technologie

| Warstwa | Narzędzie | Rola |
|---|---|---|
| Przechowywanie i obliczenia | Snowflake | Hurtownia danych, transformacje, procedury |
| Transformacja | SQL | DDL, DML, kontrola dostępu, automatyzacja pipeline'u |
| Wizualizacja | Power BI | Dashboard, miary DAX |
| Kontrola wersji | GitHub | Źródło prawdy dla wszystkich obiektów SQL |


### Architektura

**Bronze** - tabele źródłowe załadowane przez UI Snowflake, zachowane bez modyfikacji. - 5 surowych tabel (kopia źródła).
**Silver** - standaryzacja kolumn, zawężenie typów, wzbogacenie przez JOIN z ORDER_ITEMS, pięć pól kalkulowanych, klucze główne i obce, deduplikacja. - 3 zmodelowane tabele _ AUDIT_LOG
**Gold** - model wymiarowy (DIM_CUSTOMERS, DIM_PRODUCTS, FACT_ORDERS) oraz dziewięć dedykowanych widoków analitycznych zasilających Power BI. - 2 widoki DIM, 1 widok FACT, 9 widoków analitycznych


### Kontrola dostępu

Dostęp oparty na rolach zgodny z zasadą minimalnych uprawnień — trzy role:

| Rola | Zakres |
|---|---|
| `ENGINEER_ROLE` | Pełny odczyt/zapis - BRONZE, SILVER, GOLD |
| `ANALYST_ROLE` | Tylko odczyt - tabele i widoki GOLD |
| `VIEWER_ROLE` | Tylko odczyt - widoki GOLD |


### Warstwa Silver - transformacje

| Operacja | Szczegół |
|---|---|
| Zmiana nazw kolumn | 10 kolumn ustandaryzowanych w CUSTOMERS, ORDERS, PRODUCTS |
| Zmiana typów | `PRICE`, `SHIPPING_CHARGES` → `NUMBER(10,2)`; `SELLER_ID` → `VARCHAR(50)` |
| Wzbogacenie JOIN | `SELLER_ID`, `PRICE`, `SHIPPING_CHARGES`, `PRODUCT_ID` z BRONZE.ORDER_ITEMS |
| Pola kalkulowane | `TOTAL_ORDER_VALUE`, `ORDER_PERFORMANCE_DAYS`, `ESTIMATED_ORDER_PERFORMANCE_DAYS`, `DELIVERY_PERFORMANCE` |
| Obsługa NULL | `DELIVERY_PERFORMANCE` zwraca `unknown` gdy brak daty zatwierdzenia lub dostawy |
| Klucze | Klucze główne na wszystkich trzech tabelach; klucze obce ORDERS → CUSTOMERS, ORDERS → PRODUCTS |

### Pipeline jakości danych

Trzy procedury składowane uruchamiane sekwencyjnie, każda zapisuje do `SILVER.AUDIT_LOG`:

```
REFRESH_GOLD()
    
    ├── VALIDATE_DATA()          sprawdza NULL-owe klucze, nieprawidłowe
                                 sekwencje dat, ujemne wartości pieniężne
    
       [przerywa pipeline przy błędzie walidacji]
    
    └── CLEAN_SILVER_DATA()      usuwa rekordy z NULL-owymi kluczami,
                                 deduplikuje przez ROW_NUMBER()
```

Każde wykonanie - zaliczone lub przerwane - jest rejestrowane w AUDIT_LOG z nazwą procedury, statusem, liczbą przetworzonych wierszy i opisowym komunikatem.

### Dashboard - kluczowe metryki

| Metryka | Wartość |
|---|---|
| Łączna liczba zamówień | 87 000 |
| Łączny przychód | 33,79M $ |
| Średnia wartość zamówienia | 386,53 $ |
| Opóźnione | 6,41% |
| Na czas | 1,30% |
| Wcześniejsze | 92,29% |

### Analiza

#### Strategia szacowania czasu dostawy
92,29% zamówień dociera przed szacowaną datą dostawy; tylko 1,30% dokładnie na czas. Niemal całkowity brak wyników "on time" wskazuje, że daty ESTIMATED_DELIVERY są systematycznie zawyżane - celowa strategia *under-promise, over-deliver*, która maksymalizuje wskaźniki satysfakcji klientów kosztem ukrycia rzeczywistej efektywności operacyjnej.

#### Geograficzna koncentracja opóźnień
Top 10 miast z największymi opóźnieniami - Santa Cruz De Goias, Adhemar De Barros, Arace - to małe, odległe miejscowości ze średnim czasem dostawy przekraczającym 100 dni. Wolumen zamówień koncentruje się gęsto w południowo-wschodniej Brazylii, gdzie infrastruktura jest najsilniejsza. Dane ujawniają strukturalne, dwupoziomowe doświadczenie dostawy: klienci miejscy otrzymują szybkie, wcześniejsze dostawy; klienci z obszarów wiejskich borykają się z systemowymi opóźnieniami wynikającymi z luk w logistyce ostatniej mili.

#### Opóźnienia na poziomie kategorii produktów
*Zabawki* zajmują najgorszą pozycję wśród kategorii produktów pod względem wolumenu opóźnionych zamówień. Pokrywa się to z przewidywalnymi sezonowymi skokami popytu (Boże Narodzenie, ferie), które nasycają zdolności przewozowe. Wzorzec wskazuje na cykliczny, przewidywalny problem - możliwy do rozwiązania przez sezonowe planowanie zdolności, a nie stałe inwestycje infrastrukturalne.

#### Wskaźnik opóźnień a przychody: rozdzielenie
Miesięczne wskaźniki opóźnień osiągają szczyty niezależnie od szczytów przychodów. Wysoki wolumen zamówień nie jest głównym czynnikiem opóźnień - wąskie gardła operacyjne (dostępność przewoźników, przepustowość magazynów, obsługa produktów) powodują skoki opóźnień niezależnie od ogólnego wolumenu.

#### Koszt wysyłki jako sygnał opóźnienia
Opóźnione zamówienia mają konsekwentnie wyższą medianę kosztu wysyłki (~38 BRL) w porównaniu do wcześniejszych (~36 BRL) i na czas (~34 BRL). Wzorzec ten może odzwierciedlać dwa nakładające się efekty: cięższe lub większe produkty są z natury trudniejsze do efektywnego trasowania, a ekspresowa wysyłka jest stosowana reaktywnie w celu częściowego ratowania opóźnionych przesyłek - generując koszty bez rozwiązania podstawowego problemu routingu.


### Jak uruchomić projekt

> **Uwaga:** `SUPPLY_CHAIN_DB`, wszystkie schematy i tabele Bronze zostały utworzone przez UI Snowflake. Ich DDL zamieszczono w README dla celów odtworzenia.

```
1. sql/00_Preparation/        konfiguracja ról, użytkowników, uprawnień
2. sql/01_silver/             budowa i zasilenie Silver (01 → 07 w kolejności)
3. sql/02_gold/               wdrożenie widoków bazowych, następnie analitycznych
4. sql/03_procedures/         wdrożenie procedur składowanych
5. CALL SILVER.REFRESH_GOLD() wykonanie pełnego pipeline'u
6. Power BI                   połączenie ze Snowflake, widoki warstwy Gold
```
### Baza wykorzystana w projekcie: https://www.kaggle.com/datasets/bytadit/ecommerce-order-dataset
