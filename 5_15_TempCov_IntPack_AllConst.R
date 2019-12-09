#' ---
#' title: "Figure 5.15 and Summary Figure"
#' author: "Temporal Coverage using Interval Packaging"
#' ---
# Plot Temporal Coverage by Interval Packaging for Walker Delta Plain Vanilla
library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database all 3 Constellations
res <- sqlQuery(
  ch,
  paste(
    "select distinct a.StartDate,b.StartTime,b.EndTime,DATEDIFF(SS,b.StartTime,b.EndTime) as Duration
 from [GMAT].[dbo].[TempCovWalkPlain] a
    cross apply [GMAT].[dbo].[tvf_IntPackPlain] (a.StartDate) b
    where StartDate <> '2017-06-04' and StartDate <> '2018-05-30'
    order by a.StartDate"
  )
  )
resl <- sqlQuery(
  ch,
  paste(
    "select distinct a.StartDate,b.*,DATEDIFF(SS,b.StartTime,b.EndTime) as Duration 
from [GMAT].[dbo].[TempCovWalkLayer] a
cross apply [GMAT].[dbo].[tvf_IntPackLayer] (a.StartDate) b
    where StartDate <> '2017-06-04' and StartDate <> '2018-05-30'
    order by a.StartDate"
  )
  )
resJ <- sqlQuery(
  ch,
  paste(
    "	select distinct a.StartDate,b.*,DATEDIFF(SS,b.StartTime,b.EndTime) as Duration 
	from [GMAT].[dbo].[TempCovJ2Layer] a
cross apply [GMAT].[dbo].[tvf_IntPackJ2Layer] (a.StartDate) b
where StartDate <> '2017-06-04' and StartDate <> '2018-05-30'
    order by a.StartDate"
  )
)

close(ch)
df<-res
df$Constellation<-'Walker Delta'
dfl<-resl
dfl$Constellation<-'Walker Delta Layered'
dfj<-resJ
dfj$Constellation<-'J2 Layered'
df<-rbind(df,dfl,dfj)
df$StartDate<-as.Date(df$StartDate)
df$Month_Yr <- format(as.Date(df$StartDate), "%Y-%m")
library(dplyr)
#Summarize DataFrame to calculate Total duration per Day
df.Day<-df%>% group_by(StartDate,Constellation)%>%
  dplyr::summarize(TotalDuration=sum(Duration))
#Calculate Percentage of Coverage per Day
df.Day$TemCov<-df.Day$TotalDuration/86400
#Plot for Conclusion Graphics
library(ggplot2)
ggplot(df.Day, aes(df.Day$StartDate,df.Day$TemCov)) + 
  xlab("Month") + geom_line(aes(colour = Constellation, group = Constellation),size = 1) +
  ylab("Temoporal Coverage (in %)") +
  theme_bw() +
  theme(axis.title.y = element_text(vjust = 1.5, hjust = 0.5))  +
  theme(legend.title.align = 0.5) +
  theme(axis.title.x = element_text(vjust = 0, hjust = 0.5))  +
  scale_y_continuous(labels = scales::percent, limits=c(0, 1)) +
  scale_x_date(date_breaks = "months",labels = function(x) format(x, "%b-%y"))
#Single Constellation Plot set filter to produce relevant plot
df.const <- df.Day[ which(df.Day$Constellation =='Walker Delta Layered'),]
ggplot(df.const, aes(df.const$StartDate,df.const$TemCov)) + 
  xlab("Month") + geom_line(size = 1) +
  ylab("Temoporal Coverage (in %)") +
  theme_bw() +
  theme(axis.title.y = element_text(vjust = 1.5, hjust = 0.5))  +
  theme(legend.title.align = 0.5) +
  theme(axis.title.x = element_text(vjust = 0, hjust = 0.5))  +
  scale_y_continuous(labels = scales::percent, limits=c(0, 1)) +
  scale_x_date(date_breaks = "months",labels = function(x) format(x, "%b-%y"))

#Export Table for Thesis
df.Mth<-df%>% group_by(Constellation,Month_Yr)%>%
  
dplyr::summarize(TotalDuration=sum(Duration))
library(openxlsx)
write.xlsx(df.Mth, "C:\\Users\\Lenovo\\OneDrive\\Documents\\PhD\\GMAT\\WalkerConstellation\\Total_Duration_Mth.xls") 


