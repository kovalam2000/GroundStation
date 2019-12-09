#' ---
#' title: "Figure 5.11 Empirical Cum Distribution over Theoretical GS"
#' author: "Spatial Coverage"
#' date: "June 5th, 2017"
#' ---
pass = read.delim("C:\\Users\\Lenovo\\Documents\\Cranfield\\03 GMAT\\Passes\\XW\\PolarView\\exp_all_gs.txt")
#ensure correct sorting
x1 <- c("GS1","GS2","GS3","GS4","GS5","GS6","GS7","GS8","GS9","GS10")
pass$GroundStation  <- factor(pass$GS, levels = x1)
pass<-pass[order(pass$GroundStation),]
# pass <- filter(pass, Elevation > 20)#filter data
library(dplyr)
gpass<-pass%>% group_by(GS,sat)%>%
  dplyr::summarize(sumd=sum(DurationM),Count=n())
pass <- filter(pass, GS != 'GS10')#filter data
colurs<-c("#e6194B", "#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#42d4f4", "#f032e6","#bfef45")
library(ggplot2)
ggplot(pass, aes(Elevation, colour = GroundStation)) + stat_ecdf(size = 1.2) + xlab("Elevation (deg)") +
  ylab("Cumulative Distribution") +
  xlim(0,100) + ylim(0,1) +
  theme_bw() +
  theme(axis.title.y = element_text(margin = margin(t = 5, r = 20, b = 0, l = 0),size = 13))  +
  theme(legend.title.align = 0.0) +
  theme(axis.title.x = element_text(margin = margin(t = 11, r = 20, b = 0, l = 0),size = 13)) +
  theme(axis.text = element_text(color = "black")) +
  scale_color_manual(values=colurs)+
  scale_x_continuous(breaks=c(0,20,40,60,80)) +
  scale_y_continuous(breaks=c(0,0.2,0.4,0.6,0.8,1))

  





