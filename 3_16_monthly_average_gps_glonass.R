library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(
  ch,
  paste(
    "SELECT Date,concat(MONTH(Date),YEAR(date)) AS mm_yyyy,SigType,
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
    group by Date, SigType,Time
    order by date,OnHour"
  )
  )

resg <- sqlQuery(
  ch,
  paste(
    "SELECT Date,concat(MONTH(Date),YEAR(date)) AS mm_yyyy,SigType,
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
    group by Date, SigType,Time
    order by date,OnHour"
  )
  )
close(ch)
gl <- as.data.frame(res)# convert to dataframe
gl$system<-'GLONASS'
gps<- as.data.frame(resg)
gps$system<-'GPS'
gl$month <- format(gl$Date,format ="%b %Y")
gps$month <- format(gps$Date,format ="%b %Y")
library(plyr)
gps$SigType = as.character(gps$SigType)
gl$SigType = as.character(gl$SigType)
gps$SigType <- revalue(gps$SigType,c("1"="GPS L1CA","7"="GPS L5Q"))
gl$SigType <- revalue(gl$SigType,c("1"="GLONASS L1CA","4"="GLONASS L2P"))
df<-rbind(gps,gl)
library(dplyr)
diur<-df%>% group_by(SigType,OnHour)%>%
  dplyr::summarize(average=mean(S4),Count=n())
diur$OnHour = format(diur$OnHour,format='%H:%M')
names(diur)[1]<-'Signal Type'
#ggtitle("Hourly Average S4 Corrected over 12 Months") +
library(ggplot2)
ggplot(diur, aes(OnHour,average,colour=`Signal Type`,group=`Signal Type`)) + 
  xlab("Time [Hr]") + geom_line(aes(linetype =`Signal Type`),size = 0.9) +
  ylab("Average S4 Corrected") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(hjust = 0.5,vjust = 1.5)) +
  theme(axis.title.y = element_text(vjust = 1))  +
  theme(axis.text = element_text(colour = "black"))
# "Hourly Occurrence of S4 Events over 12 Months"
ggplot(diur, aes(OnHour,Count,colour=`Signal Type`,group=`Signal Type`)) + 
  xlab("Time [Hr]") +  geom_line(aes(linetype =`Signal Type`),size = 0.9) +
  ylab("Number of Events") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(hjust = 0.5,vjust = 1.5)) +
  theme(axis.title.y = element_text(vjust = 1))  +
  theme(axis.text = element_text(colour = "black"))

