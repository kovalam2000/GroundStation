library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database 5-8th June
res <- sqlQuery(
  ch,
  paste(
    "SELECT distinct date,time,Satellite,Az,Elv
    FROM [S4LogFiles].[dbo].[REDOBS_GPS_LOG]
    where date = '2017-06-08'
    "
  )
  )
gl_res <- sqlQuery(
  ch,
  paste(
    "SELECT distinct date,time,Satellite,Az,Elv
    FROM [S4LogFiles].[dbo].[REDOBS_GLONASS_LOG]
    where date = '2017-06-08'
    "
  )
  )

close(ch)
dfht <- as.data.frame(res) # convert to dataframe
dfgl <- as.data.frame(gl_res) # convert to dataframe
library(dplyr)
dfgl<-filter(dfgl,dfgl$Satellite != 24)
dfht<-filter(dfht,dfht$Satellite != 28)
# dfht$l_elv = dfht$Elv
dfht$Elv = 90-dfht$Elv
dfgl$Elv = 90-dfgl$Elv
library(plotrix)
polar.plot(dfht$Elv,dfht$Az, labels=c("N","W","S","E"), start = 90,
           rp.type = "s", point.symbols=15, point.col = "blue" ,
           clockwise = FALSE,radial.lim=c(0,30,60,90),boxed.radial=FALSE,
           label.pos = c(0,90,180,270),show.radial.grid=TRUE,main = "",
           radial.labels=c("90°","","","0°"))

polar.plot(dfgl$Elv,dfgl$Az, labels=c("N","W","S","E"), start = 90,
           rp.type = "s", point.symbols=15, point.col = "red" ,
           clockwise = FALSE,radial.lim=c(0,30,60,90),boxed.radial=FALSE,
           label.pos = c(0,90,180,270),show.radial.grid=TRUE,main = "",
           radial.labels=c("90°","","","0°"))

#adding to existing plot.
# polar.plot(dfgl$Elv,dfgl$Az, labels=c("N","W","S","E"), start = 90,
#            rp.type = "s", point.symbols=16, point.col = "red" ,radial.lim=c(0,30,60,90), add=TRUE)
# col.labels<-c("GPS","GLONASS")
# testcol<-c("blue","red")
# legend(x=110,y=100,legend=col.labels,col=testcol,pch=c(15,16),
#        bty = "n")

# #doesn't work somehow.
# radial.plot.labels(dfht$l_elv,dfht$Az,units = "polar",radial.lim = c(0,90),
#                    clockwise = FALSE, labels = as.character(dfht$Satellite))

