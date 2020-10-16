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

sortBundesland <- function(data) {
  lands <- unique(data$Bundesland)
  for (l in lands) {
    print(l)
    print(sum(data[data$Bundesland == l,]$AnzahlFall))
  }
}

moving_average <- function(values, window) {
  res = vector(length = length(values) - window + 1)
  for (i in 1:(length(values)-window + 1)) {
    res[i] = values[i]
    for (j in 1:(window - 1)) {
      res[i] = res[i] + values[i + j]
    }
  }
  return(res/window)
}

rki.moving_average_plot <- function() {
  df <- rki.load()
  IDR <- rki.getIDR(df)
  plot(moving_average(IDR$infections, 7))
}

rki.cumsum_plot <- function(till) {
  df <- rki.load()
  IDR <- rki.getIDR(df)
  plot(cumsum(IDR$infections)[1:till])
}