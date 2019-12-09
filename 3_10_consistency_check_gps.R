library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(
  ch,
  paste(
    "SELECT Date,concat(MONTH(Date),YEAR(date)) AS mm_yyyy,SigType,Satellite,
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
    and SigType = 1
    and [S4 Cor] > 0.05
    group by Date, SigType,Time,Satellite
    order by date,OnHour"
  )
  )

resg <- sqlQuery(
  ch,
  paste(
    "SELECT Date,concat(MONTH(Date),YEAR(date)) AS mm_yyyy,SigType,Satellite,
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
    and SigType = 1
    and [S4 Cor] > 0.05
    group by Date, SigType,Time,Satellite
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
#------------SWITCH GPS GLONASS----------
#switch gps for gps and gl for GLONASS
df<-gps
#----------------------------------------
df$Satellite<-paste('G',df$Satellite,sep = "")
library(dplyr)
diur<-df%>% group_by(Satellite,SigType,OnHour)%>%
  dplyr::summarize(average=mean(S4),Count=n())
diur$OnHour = format(diur$OnHour,format='%H:%M')
diur<-filter(diur,Satellite != "G24" && Satellite != "G28")

names(diur)[2]<-'Signal.Type'
# "Hourly Average S4 Corrected over 12 Months per Satellite"
library(ggplot2)
ggplot(diur, aes(OnHour,average,colour=Satellite,group=Satellite)) + 
  xlab("Time [Hr]") + geom_line() +
  ylab("Average S4 Corrected") +
  ylim(0,0.2) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(hjust = 0.5,vjust = 1.5)) +
  theme(axis.title.y = element_text(vjust = 1))  +
  theme(legend.title = element_text(size = 11)) +
  theme(axis.text = element_text(colour = "black")) +
  guides(colour=guide_legend(ncol=2))
# "Hourly Occurrence of S4 Events over 12 Months per Satellite")
ggplot(diur, aes(OnHour,Count,colour=Satellite,group=Satellite)) + 
  xlab("Time [Hr]") + geom_line() +
  ylab("Number of Scintillation Events") +
  ylim(0,1000) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(hjust = 0.5,vjust = 1.5)) +
  theme(axis.title.y = element_text(vjust = 1))  +
  theme(legend.title = element_text(size = 11)) +
  theme(axis.text = element_text(colour = "black"))+
  guides(colour=guide_legend(ncol=2)) 


