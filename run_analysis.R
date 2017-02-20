library(data.table)
library(dplyr)
setwd("./UCI HAR Dataset")


# Read only the feature names we need ( first 6 )
features <- read.table('./features.txt', header=FALSE, 
		       stringsAsFactors = FALSE)[,2]

# read in the activity labels
act_lab <-read.table("./activity_labels.txt")

# read only the data needed for assignment
subj_test <- read.table('./test/subject_test.txt')
y_test <- read.table('./test/y_test.txt')
x_test <- read.table('./test/X_test.txt')

subj_train <- read.table('./train/subject_train.txt')
y_train <- read.table('./train/y_train.txt')
x_train <- read.table('./train/X_train.txt')

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
# We only need to select columns with Mean() and Std() only.
colIdxFun <- function(x) {
	if (re_matches(x, "mean|std"))
		if(re_matches(x, "Freq"))
			FALSE
	else
		TRUE
	else
		FALSE
}
# colidx will have an index of all features with MEAN and STD in the name
colIdx <- sapply(features, colIdxFun)
names(colIdx)<- NULL

# select the column indexes and make sure we add subject and activity columns (1,2)
# this will get the column numbers
cols2Read <- c(1,2,data.frame(seq(3,563))[colIdx,])

allrecs <- allrecs[,..cols2Read]
write.table(allrecs, "../measurements.csv", row.names=FALSE, quote=FALSE,sep=",")


grouped_means <- allrecs %>% 
   group_by(activity, subject) %>% 
   summarize_each(funs(mean))

write.table(grouped_means, "../grouped_means.csv", row.names=FALSE, quote=FALSE,sep=",")
setwd("..")
