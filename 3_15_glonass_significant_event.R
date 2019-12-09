# SQL Read ----------------------------------------------------------------
library(RODBC)
ch <- odbcConnect("localdb")
# read daytime data
res <- sqlQuery(ch, paste("
  SELECT Time,Elv,[S4 Cor] as S4
  FROM [S4LogFiles].[dbo].[REDOBS_GLONASS_LOG]
  where [Lock Time] > 60
   and Date = '2017-05-20'
   and Elv > 40
  and [CMC Avg] between -0.5 and 0.5
  order by 1 asc"))

close(ch)
#write two datasets
sat25 <- as.data.frame(res) # convert to dataframe
sat25$Time = strptime(sat25$Time,format='%H:%M')
#HARDCODED Date change to current DATE when running program
lims <- as.POSIXct(strptime(c("2018-11-08 00:00","2018-11-08 23:59"), format = "%Y-%m-%d %H:%M"))
sat25$col<-ifelse((sat25$Elv > 40 & sat25$S4 > 0.15),"red","darkblue")

#plot night as points and day as line
library(ggplot2)
ggplot(sat25, aes(Time, S4)) + 
  geom_point(colour = sat25$col)+ 
  ylab(" S4 Corrected") +
  ylim(0,1) +
  scale_x_datetime("Time [Hr]",date_labels = '%H:%M',date_breaks = '2 hours', limits = lims)  +
  theme_bw()  +
 theme(axis.title.y = element_text(vjust = 1)) +
  theme(axis.text = element_text(colour = "black"))


                
