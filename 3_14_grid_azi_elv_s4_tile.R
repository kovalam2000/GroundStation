#spatial distribution of s4 for azimuth and elevation
library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(
  ch,
  paste(
    "SELECT Az,Elv,[S4 Cor] as S4
  FROM [S4LogFiles].[dbo].[REDOBS_GLONASS_LOG]
    where [CMC Avg] between -0.5 and 0.5
    and [Lock Time] > 60
 --  and MONTH(date) = '12'
    order by 2,1"
  )
  )


close(ch)
df <- as.data.frame(res) # convert to dataframe
df<-df[df$Elv>20,]

library(ggplot2)
ggplot(df, aes(Az, Elv)) +
  geom_tile(aes(colour = S4), size = 2) +
  scale_colour_gradient(low = "lightblue",high = "red") +
  scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80,90)) +
  scale_x_continuous(breaks = c(0,45,90,135,180,225,270,315,360))+
  ylab("Elevation (°)")+
  xlab("Azimuth (°)") +
  theme_bw() +
 theme(axis.text = element_text(colour = "black")) 



