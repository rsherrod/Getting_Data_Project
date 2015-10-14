setwd("C:\\Training\\Getting_data")

library(data.table)

fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipname <- "./data/getdata-UCI HAR Dataset.zip"

#create data folder
if (!file.exists("data")) {
        dir.create("data")
}

#unzip the file
if (!file.exists(zipname)){
        download.file(fileurl, destfile=zipname, mode="wb")
        unzip(zipname, exdir="./data")
}

#read data
features<- read.table("./data/UCI HAR Dataset/features.txt",stringsAsFactors=F)
activity_label<- read.table("./data/UCI HAR Dataset/activity_labels.txt",stringsAsFactors=F)

testing_subjects<- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
training_subjects<- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

test_activity<- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
train_activity<- read.table("./data/UCI HAR Dataset/train/Y_train.txt")

subject_activity<- rbind(test_activity,train_activity)  

test_feature_readings<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
train_feature_readings<-read.table("./data/UCI HAR Dataset/train/X_train.txt")

feature_readings<-rbind(test_feature_readings ,train_feature_readings) 

#combine test/train and add features/activities
tidy_dataset<- rbind(testing_subjects,training_subjects)
tidy_dataset<- cbind(tidy_dataset, subject_activity)
colnames(tidy_dataset)<- c("Subjects","Activity")  
names(feature_readings)<- features[,2]
tidy_dataset <- cbind(tidy_dataset,feature_readings)

#this dataset has all rows/columns
tidy_dataset2 <- merge(activity_label, tidy_dataset, by.x="V1", by.y="Activity")[,-1]
names(tidy_dataset2)[1]='Activity'

#extract columns representing mean and standard deviation
extract<- grep("(mean|std)",colnames(tidy_dataset2),value=T)

#subset with relevant columns
tidy_dataset2<- tidy_dataset2[,c("Subjects","Activity",extract)]

#create descriptive activity names to name the activities in the data set
tidy_dataset2$Activity<- gsub("SITTING","Sitting",tidy_dataset2$Activity)
tidy_dataset2$Activity<- gsub("STANDING","Standing",tidy_dataset2$Activity)
tidy_dataset2$Activity<- gsub("LAYING","Laying",tidy_dataset2$Activity)
tidy_dataset2$Activity<- gsub("WALKING_UPSTAIRS","Walking Up",tidy_dataset2$Activity)
tidy_dataset2$Activity<- gsub("WALKING_DOWNSTAIRS","Walking Down",tidy_dataset2$Activity)
tidy_dataset2$Activity<- gsub("WALKING","Walking",tidy_dataset2$Activity)

#remove [/(/)] from the column names
colnames(tidy_dataset2)<- gsub("[/(/)]","",colnames(tidy_dataset2))

#remove - from the column names and replace with _
colnames(tidy_dataset2)<- gsub("-","_",colnames(tidy_dataset2))

#convert to data table to simplify mean calculation
tidy_dataset2 <- data.table(tidy_dataset2)
tidy_dataset2<- tidy_dataset2[,lapply(.SD,mean),by="Subjects,Activity"]
tidy_dataset2<- tidy_dataset2[order(tidy_dataset2$Subjects),]

#output csv/txt file to working directory
write.csv(tidy_dataset2,"./github/Getting_data_Project/Tidy_Data.csv",row.names=F)
write.table(tidy_dataset2,"./github/Getting_data_Project/Tidy_Data.txt",row.names=F)

