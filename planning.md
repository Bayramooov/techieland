framework_name: Musab, Parvoz, Makon, Orzu, Osmon, Falak, Koinot

Musab - (M)usab - (required) - framework itself - base framework itself no logic at all
core - (K)ernel - (required) - framework project - minimal and core logic of applications
license - licen(S)e - (optional) - core project module for product licenses per user per module etc...

solved! TODO-issue: database connection pool must be called once !!! (not in every module)
waiting! TODO-issue: error handling must be done globally (responce.json like { success: false, ... })
waiting! TODO-task: exchanging json standart template must be created
waiting! TODO-task: response statuses must be set properly
waiting! TODO-task: developing client side of the program
(https://dashboardpack.com/bootstrap-templates/free-themes/)
(https://dashboardpack.com/live-demo-free/?livedemo=2380)

#idea
Authorization:
  updating client cookie in every request.
  Adding extra 5 minuts to expire the access token.
  Adding system settings to set the expiration duration (default: 5mins)

---

## -- TECHIE-FRAMEWORK (angular/golang or nodejs/posgreSql - no pl/pgsql for back-end!!!)

- techie-layout design should be done
- authentication
- tc-stream
- tc-grid with tc-stream
- tc-input with tc-stream
- file (upload/download)
- drag & drop
- notifications
- hot-keys (hot-key-setting)
- telegram-bot
- audit
- translate module
- OOP based nodejs/golang instrument for working with database (FAZO, fazo_query(stream)):
  every table is gonna be a Class with its Z-package methods
  they will be generated automatically.
- Z-packages - in the database and also in the server side as classes with methods
- installer page in the web which fills the env.js and executes the tables etc...
- ...

---

## -- CORE-GLOBAL (company-head)

routes:
route_id
route_type (auth, public, company-head-only)
...

companies:
company_id
...

company_routes:
company_id
route_id
...

coupons:
coupon_id
...

licenses:
license_id
company_id
issue_date
dueto_date
is_paid
coupon_id => coupons
...

layout_lang:
language_id
...

---

## -- CORE-LOCAL

-- REF
countries:
company_id
country_id
...

regions:
company_id
region_id
country_id => countries
...

currencies:
currency_id
...

--
filials: (+filial-head)
company_id
filial_id
company_id => companies
...

persons:
company_id
person_id
...

users:
company_id
user_id
company_id
person_id => persons
...

user_grants:
company_id
user_id
...

notifications:
company_id
notification_id
...

- Survey module (not urgent)
  ./survey -- TODO: should be converted to pgsql

---

## -- HR

divisions:
company_id
division_id
...

robots:
company_id
robot_id
...

---

## -- ACADEMY

- LMS
- video tutorials (private/public)
- assignments with deadlines
- quizs
- contest
- attendance (offline/online)
- ...

---

## -- QUIZ

- Quiz module (urgent!)
  ./quiz -- TODO: should be converted to pgsql
- shuffle the exam paper
- scheduling the exam
- start/pause/continue the exam
