# General data tools

rki.load <- function() {
  rki <- read.csv("./data/RKI_COVID19.csv")
  rki$Meldedatum <- as.Date(as.character(rki$Meldedatum))
  return(rki)
}

rki.getIDR <- function(df) {
  df <- df[c("Meldedatum", "AnzahlFall", "AnzahlTodesfall", "AnzahlGenesen")]
  names(df) <- c("date", "infections", "deaths", "recovered")
  df <- aggregate(df[,2:4], FUN=sum, by=list(date=df$date))
}