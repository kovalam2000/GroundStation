#' ---
#' title: "Figure 5.9 Coverage of Cranfield"
#' author: "Spatial Coverage"
#' date: "June 5th, 2017"
#' ---
XW_2B = read.delim("C:\\Users\\Lenovo\\Documents\\Cranfield\\03 GMAT\\Passes\\XW\\PolarView\\exp_XW2B.txt")
TISAT_1 = read.delim("C:\\Users\\Lenovo\\Documents\\Cranfield\\03 GMAT\\Passes\\XW\\PolarView\\exp_TISAT.txt")
XW_2F = read.delim("C:\\Users\\Lenovo\\Documents\\Cranfield\\03 GMAT\\Passes\\XW\\PolarView\\exp_XW2F.txt")
dfht <- as.data.frame(XW_2B) # convert to dataframe
dfht$Elevation = 90-dfht$Elevation
dfht$Azimuth = 360-dfht$Azimuth
df2b <- as.data.frame(TISAT_1) # convert to dataframe
df2b$Elevation = 90-df2b$Elevation
df2b$Azimuth = 360-df2b$Azimuth
df2f <- as.data.frame(XW_2F) # convert to dataframe
df2f$Elevation = 90-df2f$Elevation
df2f$Azimuth = 360-df2f$Azimuth
library(plotrix)
polar.plot(dfht$Elevation,dfht$Azimuth, labels=c("N","W","S","E"), start = 90,
           rp.type = "s", point.symbols=15, point.col = "blue" ,
           clockwise = FALSE,radial.lim=c(0,90),boxed.radial=FALSE,
           label.pos = c(0,90,180,270),show.radial.grid=TRUE,main = "Cranfield Spatial Coverage",
           radial.labels=c("90°","","","","","0°"))
polar.plot(df2b$Elevation,df2b$Azimuth, labels=c("N","W","S","E"), start = 90,
           rp.type = "s", point.symbols=16, point.col = "red" ,radial.lim=c(0,90),
           radial.labels=c("90°","","","","","0°"), add=TRUE)
polar.plot(df2f$Elevation,df2f$Azimuth, labels=c("N","W","S","E"), start = 90,
           rp.type = "s", point.symbols=16, point.col = "green" ,radial.lim=c(0,90),
           radial.labels=c("90°","","","","","0°"), add=TRUE)

col.labels<-c("XW-2B","TISAT_1","XW-2F")
testcol<-c("blue","red","green")
legend(x=110,y=100,legend=col.labels,col=testcol,pch=c(15,16,16),title = "Satellites",
       bty = "n")




