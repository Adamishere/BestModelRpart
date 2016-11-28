#auto decision tree selection function
"""
Takes 3 values
  xdata - Dataframe - Analytic dataset
  xmodel - Formula - Model Formula 
  xlabel - String - Labeling for output

Creates Final model output text file, ROC plot, and final decision tree in './output/'
Autoprunes final tree based on Breiman's 1-SE rule.

Returns a final pruned rpart model
"""

treemaker<-function(xdata,xmodel,xlabel){
  
  #creating a decision tree model
  #first build a model with a very large over fit tree
  mmptree.start<-rpart(xmodel, data=xdata, cp=.0001, method="class")
  #Visually inspect the cross validation error
  #Select size of the tree based on where the cross validation is the smallest(ie., model does not begin to over fit)
  plotcp(mmptree.start)
  #table of cross validation errors, alternative view
  printcp(mmptree.start)
  
      #select the small CP associated with the smallest cross validation error(xerror) within one standard error, store as bestcp
      # 1-SE rule (Breiman et al.,1984)
      
      #best xerror
      onese<-(mmptree.start$cptable[which.min(mmptree.start$cptable[,"xerror"]),])
        #1-SE error away from best xerror
        onese1<-as.numeric((onese['xerror']+onese['xstd']))
        
        #Set so if your model is really bad, don't build a worse tree
        onese2<-ifelse(onese1>1, 1, onese1)
      
      #convert table into dataframe for clearer data handling
      cptable<-as.data.frame(mmptree.start$cptable)
        #create value to sub, allowing for smaller trees rather than 'best' tree
        cpsubset<-cptable[cptable$xerror==onese['xerror'],'nsplit']
      
        #subset to cps with xerror less than 1-SE
        cptable1<-cptable[cptable$xerror<=onese2 & cptable$nsplit<=cpsubset,]
        
      #store corresponding CP with largest error within 1SE of smallest xerror
      bestcp<-cptable1[which.max(cptable1$xerror),'CP']
      
  mmptree.final<-prune(mmptree.start, cp=bestcp)
  print(mmptree.final)
  summary(mmptree.final)
  
  #score function, produce predictions
  xdata$pred1<-predict(mmptree.final,xdata)
  xdata$pred2<-predict(mmptree.final,xdata, type="class")
  
  #subset to prob of 1
  out1<-as.data.frame(xdata$pred1)
  
  #Produce AUC measure
  rpauc<-roc(xdata[,paste(xmodel[2])],out1[,2])
  jpeg(paste('output/',xlabel,' - ROC plot.jpg',sep=''),800,600)
  plot(rpauc,cex=2)
  dev.off()
  
  #confusion matrix
  sink(paste('output/',xlabel,' - model output.txt',sep=''))
  print("Starting model output")
  printcp(mmptree.start)
  print(paste("Best CP cutpoint:",bestcp))
  
  print("Final model output")
  printcp(mmptree.final)
  
  print(paste(cat("\n\n\n\n\n Final AUC metric\n")))
  print(rpauc)
  
  print(cat("\n\n\n\n\n Final Confusion Matrix\n"))
  print(table(xdata[,paste(xmodel[2])],as.numeric(xdata$pred2)))
  
  print(cat("\n\n\n\n\n Final model summary\n"))
  print(summary(mmptree.final))
  sink()
  
  #Plot Final Tree
  jpeg(paste('output/',xlabel,' - Final Tree.jpg',sep=''),2400,1800)
  prp(mmptree.final, fallen.leaves = FALSE, type=4, extra=4, varlen=0, faclen=0, compress=FALSE, ycompress=TRUE, box.palette = "auto",cex=2)
  dev.off()
  
  return(mmptree.final)
}