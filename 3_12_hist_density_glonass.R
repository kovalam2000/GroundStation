library(RODBC)
ch <- odbcConnect("localdb")
date <- '2016-07-04'
# read from mssql database
res <- sqlQuery(
  ch,
  paste(
    "SELECT Date, Time,elv,SigType,
    month(date) as Month,
    case when MONTH(date) in ('3','4','5') then 'Spring'
    when MONTH(date) in ('6','7','8') then 'Summer'
    when MONTH(date) in ('9','10','11') then 'Fall'
    when MONTH(date) in ('12','1','2') then 'Winter'
    end as 'Season',
    [S4 Cor] as S4
    FROM [S4LogFiles].[dbo].[REDOBS_GPS_LOG]
    where Elv > 20
    and [CMC Avg] between -0.5 and 0.5
     and [Lock Time] > 60
    and [S4 Cor] > 0.1"
  )
  )
close(ch)
test <- as.data.frame(res) # convert to dataframe
test.sub1 = subset.data.frame(test,test$Season == 'Winter')#create winter subset
hist(
  test$S4,
  xlab = "S4 Corrected",
  ylab = "Number of Data Points",
  main = "",
  col = "darkblue",
  breaks = 15
) #reads4data
library(ggplot2)
#Density Plot per Season
ggplot(test, aes(test$S4, colour = Season, fill = Season)) +
  geom_density(alpha = 0.1) + 
  labs(x = "S4 Corrected") +
  ylab("Density")+
  theme_bw() +
  theme(axis.title.y = element_text(vjust = 1)) +
  theme(axis.text = element_text(colour = "black"))+
  theme( legend.key=element_rect(fill=NA))

  
