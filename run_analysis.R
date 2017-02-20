library(data.table)
library(dplyr)
setwd("./UCI HAR Dataset")

# read only the first 6 of 561 columns as needed by the assignment
# 3 means and 3 std deviations and set the rest to NULL
cols2Read <- c(rep(NA,6),rep("NULL",555))

# Read only the feature names we need ( first 6 )
features <- read.table('./features.txt', header=FALSE, 
		       stringsAsFactors = FALSE, nrows = 6)[,2]

# read in the activity labels
act_lab <-read.table("./activity_labels.txt")

# read only the data needed for assignment
subj_test <- read.table('./test/subject_test.txt')
y_test <- read.table('./test/y_test.txt')
x_test <- read.table('./test/X_test.txt', colClasses = cols2Read)

subj_train <- read.table('./train/subject_train.txt')
y_train <- read.table('./train/y_train.txt')
x_train <- read.table('./train/X_train.txt', colClasses = cols2Read)

# convert these to data tables for easy merging
act_lab <- as.data.table(act_lab)
y_test <-as.data.table(y_test)
y_train <-as.data.table(y_train)

#bind all columns and merge activity labels
test_recs <- cbind(subj_test, merge(y_test, act_lab)[,2], x_test)
train_recs <- cbind(subj_train, merge(y_train, act_lab)[,2], x_train)

#bind all rows
allrecs <- as.data.table(rbind(train_recs, test_recs))

#label columns
colnames(allrecs) <- c("subject", "activity", features)
allrecs$subject <- as.factor(allrecs$subject)

# allrecs now has all the rows as specified in the assignment.
write.table(allrecs, "../measurements.csv", row.names=FALSE, quote=FALSE,sep=",")


grouped_means <- allrecs %>% 
   group_by(activity, subject) %>% 
   summarize( 
   	AverageBodyAccMeanX=mean(`tBodyAcc-mean()-X`),
   	AverageBodyAccMeanY=mean(`tBodyAcc-mean()-Y`),
   	AverageBodyAccMeanZ=mean(`tBodyAcc-mean()-Z`),
   	AverageBodyAccStdX=mean(`tBodyAcc-std()-X`),
   	AverageBodyAccStdY=mean(`tBodyAcc-std()-Y`),
   	AverageBodyAccStdZ=mean(`tBodyAcc-std()-Z`)
   	)

write.table(grouped_means, "../grouped_means.csv", row.names=FALSE, quote=FALSE,sep=",")
setwd("..")
