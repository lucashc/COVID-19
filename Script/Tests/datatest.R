source("./Script/Functions/datatools.R")
df <- rki.load()
IDR <- rki.getIDR(df)

plot(IDR$date, IDR$infections)