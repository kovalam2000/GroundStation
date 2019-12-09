# Sys.setlocale("LC_ALL", "English")
library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(
  ch,
    "SELECT Date, Time,elv,SigType,
[S4 Cor] as S4
    FROM [S4LogFiles].[dbo].[REDOBS_GPS_LOG]
    where Elv > 20
    and [CMC Avg] between -0.5 and 0.5
     and [Lock Time] > 60"
  )
resf <- sqlQuery(
  ch,
  "SELECT Date, Time,elv,SigType,
  [S4 Cor] as S4
  FROM [S4LogFiles].[dbo].[REDOBS_GLONASS_LOG]
  where Elv > 20
  and [CMC Avg] between -0.5 and 0.5
  and [Lock Time] > 60
  and Satellite <> 24"
)
close(ch)
gps <- as.data.frame(res) # convert to dataframe
gl <- as.data.frame(resf) # convert to dataframe
gl$System<-'GLONASS'
gps$System<-'GPS'
all<-rbind(gl,gps)
library(ggplot2)
ggplot(all, aes(S4, color = System, linetype = System)) + stat_ecdf(size = 1) +
  ylab("Cumulative Probability") + 
  xlab("S4 Corrected") +
  theme_bw() + 
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(hjust = 0.5,vjust = 1.5)) +
  theme(axis.title.y = element_text(vjust = 1.2))  +
  theme(axis.text = element_text(colour = "black")) +
  theme(legend.title.align = 0.5)

