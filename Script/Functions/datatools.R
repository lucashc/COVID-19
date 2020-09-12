# General data tools

rki.load <- function() {
  return(read.csv("./Data/RKI_COVID19.csv"))
}

rki.getIDR <- function(df) {
  df <- df[c("Meldedatum", "AnzahlFall", "AnzahlTodesfall", "AnzahlGenesen")]
  names(df) <- c("date", "infections", "deaths", "recovered")
  aggregate(df[,2:4], FUN=sum, by=list(date=df$date))
}