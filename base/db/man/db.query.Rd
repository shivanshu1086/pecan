% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_db.R
\name{db.query}
\alias{db.query}
\title{Generic function to query database}
\usage{
db.query(query, con = NULL, params = NULL, values = NULL)
}
\arguments{
\item{query}{SQL query string}

\item{con}{Database connection object}

\item{params}{Named list of database connection parameters. See
`params` argument to [db.open()].}

\item{values}{If using prepared statements, a list of values to
substitute into the query. If `NULL` (default), execute the
query directly. See this function's "Details", and documentation
for [DBI::dbBind()].}
}
\value{
data frame with query results
}
\description{
Given a connection and a query, will return a query as a data frame. Either con or params need
to be specified. If both are specified it will use con.
}
\details{
This function supports prepared statements, which provide a way to
pass data into SQL queries without the risk of SQL injection
attacks. Whenever you are tempted to do something like this:

```
db.query(paste0(
  "SELECT * FROM table WHERE mycol = ", somevalue,
  " AND othercol = ", othervalue
), con = con)
```

...use a prepared query instead:

```
db.query(
  "SELECT * FROM table WHERE mycol = $1 AND othercol = $2",
  values = list(somevalue, othervalue),
  con = con
)
```

Besides preventing SQL injections, prepared statements also ensure
that the input and target types are compatible.

Prepared statements provide an efficient way to operate on
multiple values at once. For example, the following will return
all the models whose revision is either "git", "46", or "unk":

```
db.query(
  "SELECT * FROM models WHERE revision = $1",
  values = list(c("git", "46", "unk")),
  con = con
)
```

...and here is an example of inserting multiple values of a given
trait for a given species:

```
db.query(
  "INSERT INTO traits (specie_id, variable_id, mean, n) VALUES ($1, $2, $3)",
  values = list(938, 396, c(1.7, 3.9, 4.5), 1),
  con = con
)
```

Note that prepared statements **can not be used to select tables
or columns**. In other words, the following _will not work_
because of the following placeholders, the only valid one is `$5`:

```
# This will not work!
db.query(
  "SELECT $1, $2 FROM $3 WHERE $4 = $5",
  values = list("col1", "col2", "mytable", "somecolumn", "somevalue")
)
```

Note that prepared statements **are not supported by the
`RPostgreSQL` package**; only by the newer `RPostgres` package.
}
\examples{
\dontrun{
db.query("SELECT count(id) FROM traits;", params = settings$database$bety)

# Prepared statements
con <- db.open(settings$database$bety)
db.query(
  "SELECT * FROM table WHERE mycol = $1 AND othercol = $2",
  values = list(somevalue, othervalue),
  con = con
)

# Select multiple values at once; rbind the result
db.query(
  "SELECT * FROM models WHERE revision = $1",
  values = list(c("git", "46", "unk")),
  con = con
)

# Efficiently insert multiple values into a table
db.query(
  "INSERT INTO traits (specie_id, variable_id, mean, n) VALUES ($1, $2, $3, $4)",
  values = list(938, 396, rnorm(1000), 1),
  con = con
)
}
}
\author{
Rob Kooper, Alexey Shiklomanov
}
