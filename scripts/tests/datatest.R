source("./scripts/functions/datatools.R")
df <- rki.load()
IDR <- rki.getIDR(df)

plot(IDR$date, IDR$infections)
