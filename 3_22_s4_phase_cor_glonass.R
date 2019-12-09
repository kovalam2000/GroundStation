library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(
  ch,
  paste(
    "SELECT 
      [S4 Cor] as S4
    
    ,[60SecSigma] as Phase
    FROM [S4LogFiles].[dbo].[REDOBS_GLONASS_LOG]
    where [CMC Avg] between -0.5 and 0.5
    and [Lock Time] > 240
    and Elv > 20
    and Date = '2016-12-20'
    and [60SecSigma]<0.75
    and [S4 Cor]>0.05"
  )
  )


close(ch)
df <- as.data.frame(res) # convert to dataframe
library(ggplot2)
ggplot(df, aes(S4,Phase)) + 
  xlab("S4 Corrected") + geom_point() + geom_smooth(method="lm") +
  ylab("resultant phase st dev / rad") 






