library(reshape2)
setwd("~/GitHub/datagatheringassignment")

# Read only the feature names we need ( first 6 )
features <- read.table('./UCI HAR Dataset/features.txt', header=FALSE, 
		       stringsAsFactors = FALSE)[,2]

# read in the activity labels
act_lab <-read.table("./UCI HAR Dataset/activity_labels.txt", header=FALSE)

# read only the data needed for assignment
subj_test <- read.table('./UCI HAR Dataset/test/subject_test.txt',header=FALSE)
lab_test <- read.table('./UCI HAR Dataset/test/y_test.txt')
x_test <- read.table('./UCI HAR Dataset/test/X_test.txt')

subj_train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
lab_train <- read.table('./UCI HAR Dataset/train/y_train.txt')
x_train <- read.table('./UCI HAR Dataset/train/X_train.txt')

#bind all columns and merge activity labels
test_recs <- cbind(x_test, subj_test, lab_test)
train_recs <- cbind(x_train, subj_train, lab_train)


#bind all rows
allrecs <- rbind(train_recs, test_recs)

#label columns
colnames(allrecs) <- c(features,"subject", "activity")
allrecs$subject <- as.factor(allrecs$subject)

# Descriptive activity labels
allrecs$activity <- factor(allrecs$activity, labels=as.vector(act_lab[,2]))

# We only need to select columns with Mean() and Std() only.
columns <- append(grep("mean", names(allrecs), value=TRUE), grep("std", names(allrecs), value=TRUE))
allrecs <- allrecs[, c(columns, "subject", "activity")]

write.table(allrecs, "measurements.csv", row.names=FALSE, quote=FALSE,sep=",")


groups <- melt(allrecs, id=c("subject", "activity"))
group_means <- dcast(groups, subject + activity ~ variable, mean)

write.table(group_means, "tidydata.csv", row.names=FALSE, quote=FALSE,sep=",")

