## Getting and cleaning data project

## This fuction expects the name of the directory containing the data set.
## This means the directory called "UCI HAR Dataset" unless you changed the name
## It calls combine_data to get the first tidy data set, the one with all the columns
## you want to meddle with.
## It then computes the means asked for in the project description
make_means<-function(directory="./"){
  original_set<-combine_data(directory)
  activity_labels<-read.table(paste(directory,"activity_labels.txt",sep=""))
  
  ## make a means set
  means_data<-data.frame(matrix(data = NA,nrow = 180,ncol=68))
  colnames(means_data)<-colnames(original_set)
  for (j in 1:30){
    for (i in 1:6){
      means_data[i+6*(j-1),"subject"]<-j
      means_data[i+6*(j-1),"activity_name"]<-as.character(activity_labels[i,2])
    }
  }
  
  library(sqldf)
  
  for (j in 1:180){
      query_string<-paste("SELECT * FROM original_set WHERE activity_name='",means_data[j,"activity_name"],"' AND subject=",means_data[j,"subject"],sep="")
      set<-sqldf(query_string,drv='SQLite')
      for (i in 1:66){
        means_data[j,i]<-mean(as.numeric(set[,i]))
      }
  }

  write.table(means_data,file = "tidy_set.txt",sep="\t")
  means_data
}

## This fuction expects the name of the directory containing the data set.
## This means the directory called "UCI HAR Dataset" unless you changed the name
## It calls the functions get_data_test and get_data_train, and rowbinds
## the results.  The output of this function is the first tidy data set from the
## project description.  Not the one to be submitted, but the first of two.
combine_data<-function(directory="./"){
  good_data<-rbind(get_data_test(directory),get_data_train(directory))
}

## This fuction expects the name of the directory containing the data set.
## This means the directory called "UCI HAR Dataset" unless you changed the name
## It reads the test data and makes the appropriate data frame
get_data_test<-function(directory="./"){
  can_continue<-T
  
  ## read the features.txt file
  if (can_continue==T){
    if (file.exists(paste(directory,"features.txt",sep=""))){
      ## we only need the second column of this, as the first is just a counter
      features_data<-as.character(read.table(paste(directory,"features.txt",sep=""))[,2])
      
      ## make a vector of columns containing mean() and std()
      good_columns<-c(grep("mean\\(\\)",features_data),grep("std\\(\\)",features_data))
    }
    else{
      print("Couldn't find the features.txt file.")
      can_continue<-F
    }
  }
  
  ## read the activity labels file
  if (can_continue==T){
    if (file.exists(paste(directory,"activity_labels.txt",sep=""))){
      activity_labels<-read.table(paste(directory,"activity_labels.txt",sep=""))
      
      ## add some decent names
      colnames(activity_labels)<-c("activity_number","activity_name")
    }
    else{
      print("Couldn't find the activity_labels.txt file.")
      can_continue<-F
    }
  }
  
  ## read x_test_file
  if (can_continue==T){
    if (file.exists(paste(directory,"test/","X_test.txt",sep=""))){
      x_file_data<-read.table(paste(directory,"test/","X_test.txt",sep=""))
      
      ## add the correct column names
      colnames(x_file_data)<-features_data
      
      ## only keep the good columns, the ones with mean and std
      good_data<-x_file_data[,good_columns]
    }
    else{
      print("Couldn't find the X_test.txt file.")
      can_continue<-F
    }
  }
  
  ## read the y_test_file
  if (can_continue==T){
    if (file.exists(paste(directory,"test/","y_test.txt",sep=""))){
      y_file_data<-read.table(paste(directory,"test/","y_test.txt",sep=""))
      
      ## add the correct column name
      colnames(y_file_data)<-"activity_number"
      
      ## replace numbers with activity names
      merged<-merge(y_file_data,activity_labels,by.x="activity_number",by.y="activity_number",all=T,sort = F)
      y_file_data<-merged[,"activity_name"]
      
      ## add this column to the good_data set
      good_data<-cbind(good_data,y_file_data)
      colnames(good_data)[67]<-"activity_name"
    }
    else{
      print("Couldn't find the y_test.txt file.")
      can_continue<-F
    }
  }
  
  ## read the test subject file
  if (can_continue==T){
    if (file.exists(paste(directory,"test/","subject_test.txt",sep=""))){
      subjects<-read.table(paste(directory,"test/","subject_test.txt",sep=""))
      
      ## add the correct column name
      colnames(subjects)<-"subject"
      
      ## add this column to the good_data set
      good_data<-cbind(good_data,subjects)
    }
    else{
      print("Couldn't find the subject_test.txt file.")
      can_continue<-F
    }
  }
  
  ## if some files were missing, we should return an empty
  ## data frame
  if (can_continue==F){
    good_data<-data.frame(aname=NA,bname=NA)[numeric(0),]
  }
  
  good_data
}

## This fuction expects the name of the directory containing the data set.
## This means the directory called "UCI HAR Dataset" unless you changed the name
## It reads the train data and makes the appropriate data frame
get_data_train<-function(directory="./"){
  can_continue<-T
  
  ## read the features.txt file
  if (can_continue==T){
    if (file.exists(paste(directory,"features.txt",sep=""))){
      ## we only need the second column of this, as the first is just a counter
      features_data<-as.character(read.table(paste(directory,"features.txt",sep=""))[,2])
      
      ## make a vector of columns containing mean() and std()
      good_columns<-c(grep("mean\\(\\)",features_data),grep("std\\(\\)",features_data))
    }
    else{
      print("Couldn't find the features.txt file.")
      can_continue<-F
    }
  }
  
  ## read the activity labels file
  if (can_continue==T){
    if (file.exists(paste(directory,"activity_labels.txt",sep=""))){
      activity_labels<-read.table(paste(directory,"activity_labels.txt",sep=""))
      
      ## add some decent names
      colnames(activity_labels)<-c("activity_number","activity_name")
    }
    else{
      print("Couldn't find the activity_labels.txt file.")
      can_continue<-F
    }
  }
  
  ## read the X_train.txt file
  if (can_continue==T){
    if (file.exists(paste(directory,"train/","X_train.txt",sep=""))){
      ## note we reuse x_file_data here as it's an intermediate thing we never keep
      x_file_data<-read.table(paste(directory,"train/","X_train.txt",sep=""))
      
      ## add the correct column names
      colnames(x_file_data)<-features_data
      
      ## only keep the good columns, the ones with mean and std
      good_data<-x_file_data[,good_columns] ## at the end we'll rowbind this with good_data
    }
    else{
      print("Couldn't find the X_train.txt file.")
      can_continue<-F
    }
  }
  
  ## read the y_train_file
  if (can_continue==T){
    if (file.exists(paste(directory,"train/","y_train.txt",sep=""))){
      y_file_data<-read.table(paste(directory,"train/","y_train.txt",sep=""))
      
      ## add the correct column name
      colnames(y_file_data)<-"activity_number"
      
      ## replace numbers with activity names
      merged<-merge(y_file_data,activity_labels,by.x="activity_number",by.y="activity_number",all=T,sort = F)
      y_file_data<-merged[,"activity_name"]
      
      ## add this column to the good_data set
      good_data<-cbind(good_data,y_file_data)
      colnames(good_data)[67]<-"activity_name"
    }
    else{
      print("Couldn't find the y_train.txt file.")
      can_continue<-F
    }
  }
  
  ## read the train subject file
  if (can_continue==T){
    if (file.exists(paste(directory,"train/","subject_train.txt",sep=""))){
      subjects<-read.table(paste(directory,"train/","subject_train.txt",sep=""))
      
      ## add the correct column name
      colnames(subjects)<-"subject"
      
      ## add this column to the good_data set
      good_data<-cbind(good_data,subjects)
    }
    else{
      print("Couldn't find the subject_train.txt file.")
      can_continue<-F
    }
  }
 
  ## if some files were missing, we should return an empty
  ## data frame
  if (can_continue==F){
    good_data<-data.frame(aname=NA,bname=NA)[numeric(0),]
  }
  
  good_data
}