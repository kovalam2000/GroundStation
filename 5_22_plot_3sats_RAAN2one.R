mydata = read.delim("C:\\Users\\Lenovo\\Documents\\Cranfield\\03 GMAT\\Simulation\\Plot_RAAN_Delta_Days.txt",header = TRUE,sep = "")
mydata$day<-floor(mydata$B_1.ElapsedDays)
library(tidyr)
library(dplyr)
dfRAAN<-mydata%>% group_by(day)%>%
  dplyr::summarize(B1_RAAN=max(B_1.EarthMJ2000Eq.RAAN),B2_RAAN=max(B_2.EarthMJ2000Eq.RAAN),B3_RAAN=max(B_3.EarthMJ2000Eq.RAAN))
df<-dfRAAN %>%
  gather(Satellite,RAAN, B1_RAAN:B3_RAAN)
# diff df$diff <- c(NA,dfRAAN[2:nrow(df), 2] - dfRAAN[1:(nrow(df)-1), 1])
df$Satellite<-as.character(df$Satellite)
df[df=="B1_RAAN"]<-'Satellite at 1100 km'
df[df=="B2_RAAN"]<-'Satellite at 800 km'
df[df=="B3_RAAN"]<-'Satellite at 500 km'
library(ggplot2)
ggplot(df, aes(df$day,df$RAAN)) + 
  geom_point(aes(color = Satellite,group=Satellite), size = 1.4) +
  xlab("Time (Days)") + ylab("RAAN (deg)") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(axis.title.x = element_text(vjust = 0.2)) +
  theme(axis.title.y = element_text(vjust = 1)) +
  theme(legend.title=element_blank()) +
  theme(legend.text=element_text(size=13))
# # SMA Plot
# dfSMA<-mydata%>% group_by(day)%>%
#   dplyr::summarize(B1_SMA=max(B_1.Earth.SMA),B2_SMA=max(B_2.Earth.SMA),B3_SMA=max(B_3.Earth.SMA))
# df<-dfSMA %>%
#   gather(Satellite, SMA, B1_SMA:B3_SMA)
# library(grid)
# ggplot(df, aes(df$day,df$SMA)) + 
#   geom_point(size = 0.86) + facet_grid(Satellite ~ .,scales="free_y") +
#   xlab("Time (Days)") + ylab("SMA (km)") +
#   theme_bw() +
#   theme(plot.title = element_text(hjust = 0.5)) +
#     theme(panel.margin = unit(1, "lines"))  