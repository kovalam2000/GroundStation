###---Script to plot passes and there statistics over theo.GS###
library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(ch, paste("
SELECT *
  FROM [S4LogFiles].[dbo].[VHF_SIM_PASS_ECEF]
                          where [XW_2A DateUTCGregorian] <>'2017-06-04'
                          and [XW_2A DateUTCGregorian] <>'2017-06-10'"))

rc <- sqlQuery(ch, paste("SELECT *
                             FROM [S4LogFiles].[dbo].[VHF_SIM_CONTACTS]
                           where StartDate <>'2017-06-04'
                           and StartDate <>'2017-06-10'"

                         ))

close(ch)
dfc <- as.data.frame(res) # convert to dataframe
con<-as.data.frame(rc)
col<-c("S_3CAT", "NANOS","XW_2A","DUCHI","TISAT","XW_2D","UKUBE","OSCAR","DEORB","DELFI","XW_2C","FUNCU","PCSA","XW_2F")
library(dplyr)
test1<-select(dfc,contains("Date"),contains("UTC") ,starts_with("XW_2B"))
test1$sat<-"XW 2B"
names(test1)[3:5] <- c("X","Y","Z")
test2<-select(dfc,contains("Date"),contains("UTC") ,starts_with("NANOS"))
test2$sat<-"NANOSATC BR1"
names(test2)[3:5] <- c("X","Y","Z")
test3<-select(dfc,contains("Date"),contains("UTC") ,starts_with("Xw_2A"))
test3$sat<-"XW 2A"
names(test3)[3:5] <- c("X","Y","Z")
test4<-select(dfc,contains("Date"),contains("UTC") ,starts_with("S_3CAT"))
test4$sat<-"S3CAT2"
names(test4)[3:5] <- c("X","Y","Z")
test5<-select(dfc,contains("Date"),contains("UTC") ,starts_with("DUCHI"))
test5$sat<-"DUCHIFAT 1"
names(test5)[3:5] <- c("X","Y","Z")
test6<-select(dfc,contains("Date"),contains("UTC") ,starts_with("TISAT"))
test6$sat<-"TISAT1"
names(test6)[3:5] <- c("X","Y","Z")
test7<-select(dfc,contains("Date"),contains("UTC") ,starts_with("UKUBE"))
test7$sat<-"UKUBE1"
names(test7)[3:5] <- c("X","Y","Z")
test8<-select(dfc,contains("Date"),contains("UTC") ,starts_with("OSCAR"))
test8$sat<-"OSCAR_7"
names(test8)[3:5] <- c("X","Y","Z")
test9<-select(dfc,contains("Date"),contains("UTC") ,starts_with("DEORB"))
test9$sat<-"DEORBITSAIL"
names(test9)[3:5] <- c("X","Y","Z")
test10<-select(dfc,contains("Date"),contains("UTC") ,starts_with("DELFI"))
test10$sat<-"DELFI C3"
names(test10)[3:5] <- c("X","Y","Z")
test11<-select(dfc,contains("Date"),contains("UTC") ,starts_with("XW_2C"))
test11$sat<-"XW 2C"
names(test11)[3:5] <- c("X","Y","Z")
test12<-select(dfc,contains("Date"),contains("UTC") ,starts_with("FUNCU"))
test12$sat<-"FUNCUBE 3"
names(test12)[3:5] <- c("X","Y","Z")
test13<-select(dfc,contains("Date"),contains("UTC") ,starts_with("PCSA"))
test13$sat<-" PCSAT"
names(test13)[3:5] <- c("X","Y","Z")
test14<-select(dfc,contains("Date"),contains("UTC") ,starts_with("XW_2F"))
test14$sat<-"XW 2F"
names(test14)[3:5] <- c("X","Y","Z")

a<-bind_rows(test1,test2,test3,test4,test5,test6,test7,test8,test9,test10,test11,test12,test13,test14)
names(a)[1:2]<-c("StartDate","Time")
tblex<-inner_join(a,con, by=c("sat" = "Satellite","StartDate" = "StartDate"))
tblex$Time<-as.character(tblex$Time)
tblex$StartTime<-as.character(tblex$StartTime)
tblex$EndTime<-as.character(tblex$EndTime)
tblex<-filter(tblex,tblex$Time>=tblex$StartTime&tblex$Time<=tblex$EndTime)
sel_tbl<-select(tblex,sat,GS,StartDate:Z,StartTime,EndTime,DurationM)
sel_tbl<-arrange(sel_tbl,sat,GS)

write.table(sel_tbl, "C:/Users/Lenovo/Documents/Cranfield/03 GMAT/Passes/XW/export_ecef_all_2.txt", sep=";") 
