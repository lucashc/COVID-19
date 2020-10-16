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