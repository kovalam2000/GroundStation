library(RODBC)
ch <- odbcConnect("localdb")
date <- '2016-05-08'
# read from mssql database
pre <- sqlQuery(ch, paste("SELECT satellite,date,time,Elv,SigType,[S4 Cor] as S4,S4 as SRaw
  FROM [S4LogFiles].[dbo].[REDOBS_GPS_LOG]
                         where Time < '06:00:00.0000000'
                           and Time > '04:00:00.0000000'
                           and Elv > 20
                           and [Lock Time] > 60
                           and Date = '" ,date, "' "))
# Code Carrier Divergence Corrected
post <- sqlQuery(ch, paste("SELECT satellite,date,time,Elv,SigType,[S4 Cor] as S4,S4 as SRaw
  FROM [S4LogFiles].[dbo].[REDOBS_GPS_LOG]
                        where [CMC Avg] between -0.5 and 0.5
                          and [Lock Time] > 60
                          and Time < '06:00:00.0000000'
                          and Time > '04:00:00.0000000'
                          and Elv > 20
                          and Date = '" ,date, "' "))
close(ch)
sat25_pre <- as.data.frame(pre) # convert to dataframe
sat25_post <- as.data.frame(post) # convert to dataframe
#Convert to Unix DateTime format for both dfs
t <- strptime(sat25_pre$time,"%H:%M:%S")
t_post <- strptime(sat25_post$time,"%H:%M:%S")
library(ggplot2)
#raw and corrected S4 before processing
ggplot(sat25_pre, aes(x=t, y=SRaw)) + geom_point() + 
  xlab("Time") + ylab("S4") + 
  scale_x_datetime("Time [Hr]") +
  theme(axis.text = element_text(colour = "black")) +
  ylim(0,1)
#S4 Corrected
ggplot(sat25_pre, aes(x=t, y=S4)) + geom_point() + 
  xlab("Time") + ylab("S4 Corrected") + 
  scale_x_datetime("Time [Hr] ") +
  theme(axis.text = element_text(colour = "black")) +
  ylim(0,1)
#PostProcessed Plots first raw data then corrected
ggplot(sat25_post, aes(x=t_post, y=SRaw)) + geom_point() + 
  xlab("Time") + ylab("S4") + 
  scale_x_datetime("Time [Hr]") +
  theme(axis.text = element_text(colour = "black")) +
  ylim(0,1)  
#S4 corrected
ggplot(sat25_post, aes(x=t_post, y=S4)) + geom_point() + 
  xlab("Time") + ylab("S4 Corrected") + 
  scale_x_datetime("Time [Hr]") +
  theme(axis.text = element_text(colour = "black")) +
  ylim(0,1)