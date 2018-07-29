# Load packages -----------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(nycflights13)
library(RPostgreSQL)

# Read data ---------------------------------------------------------------

data("birthwt"); birthwt <- birthwt %>% as.tibble()
data("mtcars"); mtcars <- mtcars %>% rownames_to_column("brand") %>% as.tibble()
data("flights")
data("weather")
data("planes")
data("airports")
data("airlines")

# Write to database -------------------------------------------------------
con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(), dbname="martinadata")
dbWriteTable(con, "cartable", value = mtcars, append = TRUE, row.names = FALSE)
dbWriteTable(con, "birthwttable", value = birthwt, append = TRUE, row.names = FALSE)
dbWriteTable(con, "flightstable", value = flights, append = TRUE, row.names = FALSE)
dbWriteTable(con, "weathertable", value = weather, append = TRUE, row.names = FALSE)
dbWriteTable(con, "planestable", value = planes, append = TRUE, row.names = FALSE)
dbWriteTable(con, "airportstable", value = airports, append = TRUE, row.names = FALSE)
dbWriteTable(con, "airlinestable", value = airlines, append = TRUE, row.names = FALSE)
dbDisconnect(con)

# Write table (for fun) ---------------------------------------------------

# Cars
if(FALSE) {
  sql_command <- "CREATE TABLE cartable
  (
  carname character varying NOT NULL,
  mpg numeric(3,1),
  cyl numeric(1,0),
  disp numeric(4,1),
  hp numeric(3,0),
  drat numeric(3,2),
  wt numeric(4,3),
  qsec numeric(4,2),
  vs numeric(1,0),
  am numeric(1,0),
  gear numeric(1,0),
  carb numeric(1,0),
  CONSTRAINT cartable_pkey PRIMARY KEY (carname)
  )
  WITH (
  OIDS=FALSE
  );
  ALTER TABLE cartable
  OWNER TO openpg;
  COMMENT ON COLUMN cartable.disp IS '
  ';"

  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(), dbname = "martinadata")
  dbGetQuery(con, sql_command) # Unneccesary but there for fun..
  dbDisconnect(con)
}
