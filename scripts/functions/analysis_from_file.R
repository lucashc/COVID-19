source('./scripts/RGG/source.R')

# Get files
filelist <- list.files(path="./history/", pattern="^largerun")
print(length(filelist))

histories <- lapply(filelist, function(filename) {
  load_result(tools::file_path_sans_ext(filename))$history
})

start_day = 25
end_day = 125

plotConfCumRKI(histories, start_day, end_day, 80, 0.68)
plotConfJRKI(histories, start_day, end_day, 80, 0.68)

# Histogram of maxima
maxima <- lapply(histories, function(h){max(h$J)})
hist(as.numeric(maxima), 20)

# Smoothed plot
start_day = 25
end_day = 125
total <- data.frame(histories)
indices <- grep('^J', colnames(total))
total[,indices] <- total[,indices]*scale
dat <- as.matrix(total[,grep('^J', colnames(total))])
Jmean <- apply(dat, 1, mean)
plot((start_day+3):(end_day-3), moving_average(Jmean, 7), type='l')