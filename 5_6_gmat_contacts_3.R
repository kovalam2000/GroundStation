# Script to plot passes and their statistics over theo.GS###

library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(ch, paste("
SELECT [Satellite]
      ,[GS]
      ,[StartDate]
      ,[StartTime]
      ,[EndDate]
      ,[EndTime]
      ,[Duration]
      ,[DurationM]
        FROM [GMAT].[dbo].[VHF_SIM_CONTACTS]"))

close(ch)
sat25 <- as.data.frame(res) # convert to dataframe
library(dplyr)
sat25 <- filter(sat25, StartDate != '2017-06-04' & StartDate != '2017-06-10')#filter data 
sat25 <- filter(sat25, Satellite == 'XW 2A')#filter data

#ensure correct sorting
x1 <- c("GS1","GS2","GS3","GS4","GS5","GS6","GS7","GS8","GS9","GS10")
sat25$GS  <- factor(sat25$GS, levels = x1)
sat25<-sat25[order(sat25$GS),]
library(plotrix)
sat25<-sat25%>% group_by(GS,StartDate,Satellite)%>%
  summarize(DurationM=sum(DurationM),Count=n())
sat25$Date<-as.character(sat25$StartDate)
#plot incl. smoothing
library(ggplot2)
ggplot(sat25, aes(sat25$GS,sat25$DurationM)) + 
  geom_point(aes(group = Date, colour = Date) ,alpha = 0.9) +
  geom_smooth(aes(group = 1)) +
  xlab("Ground Station") + ylab("Coverage (min)") +
  theme_bw() +
  theme(axis.title.y = element_text(angle = 90,vjust = 1.3)) +
  theme(axis.title.x = element_text(vjust = -0.2))




                
