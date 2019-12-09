library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(
  ch,
  paste(
    "SELECT SigType,
DATEPART(hour, [time]) AS OnHour,avg([S4 Cor]) as S4,
    case when MONTH(date) in ('3','4','5') then 'Spring'
    when MONTH(date) in ('6','7','8') then 'Summer'
    when MONTH(date) in ('9','10','11') then 'Fall'
    when MONTH(date) in ('12','1','2') then 'Winter'
    end as 'Season'
    FROM [S4LogFiles].[dbo].[REDOBS_GLONASS_LOG]
    where [CMC Avg] between -0.5 and 0.5
    and [Lock Time] > 60
    and Elv > 20
    group by date,SigType,Time
    order by OnHour"
  )
  )

gps <- sqlQuery(
  ch,
  paste(
    "SELECT SigType,
    DATEPART(hour, [time]) AS OnHour,avg([S4 Cor]) as S4,
    case when MONTH(date) in ('3','4','5') then 'Spring'
    when MONTH(date) in ('6','7','8') then 'Summer'
    when MONTH(date) in ('9','10','11') then 'Fall'
    when MONTH(date) in ('12','1','2') then 'Winter'
    end as 'Season'
    FROM [S4LogFiles].[dbo].[REDOBS_GPS_LOG]
    where [CMC Avg] between -0.5 and 0.5
    and [Lock Time] > 60
    and Elv > 20
    group by date,SigType,Time
    order by OnHour"
  )
  )
close(ch)
df <- as.data.frame(res) # convert to dataframe
library(plyr)
df$SigType = as.character(df$SigType)
df$SigType <- revalue(df$SigType,c("4"="GLONASS L2P","1" ="GLONASS L1CA"))
gps <- as.data.frame(gps) # convert to dataframe
gps$SigType = as.character(gps$SigType)
gps$SigType <- revalue(gps$SigType,c("7"="GPS L5Q","1" ="GPS L1CA"))
df<-rbind(df,gps)


library(dplyr)
seas<-df%>% group_by(Season,SigType,OnHour)%>%
  dplyr::summarize(average=mean(S4),Number=n(),sd=sd(S4),se=sd(S4)/sqrt(n()))
seas$OnHour = format(seas$OnHour,format='%H:%M')
names(seas)[2]<-'Signal Type'
#Seasonal Daily S4 Variation per Signal Type
library(ggplot2)
ggplot(seas, aes(OnHour,average,linetype =`Signal Type`,group = `Signal Type`)) + 
  geom_line(aes(color = `Signal Type`),size = 1) +
  ylab("Average S4 Corrected") +
  xlab("Time [Hr]") +
  facet_grid( Season ~ .) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5,vjust = 1.5)) +
  theme(axis.title.y = element_text(vjust = 1))  +
  theme(axis.text = element_text(colour = "black"))
# Only for GPS L1CA
seas_gps<-subset(seas,`Signal Type`=="GPS L1CA")
pd <- position_dodge(0.1) # move them .05 to the left and right
ggplot(seas_gps, aes(OnHour,average,group = `Signal Type`)) +
  geom_line() +
  geom_errorbar(aes(ymin=average-se, ymax=average+sd),width=.3, color = "darkblue",position = pd)+
  ylab("Average S4 Corrected") +
  xlab("Time [Hr]") +
  facet_grid( seas_gps$Season~.  ) +
  theme_bw() +
  theme(axis.title.y = element_text(vjust = 1)) +
  theme(axis.text = element_text(colour = "black"))

