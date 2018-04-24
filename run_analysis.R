# download and unzip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","SmartphoneData.zip")
TimeDownload <- date()
unzip("SmartphoneData.zip")

# read data, labels, and subjects of train and test data sets
train <- read.table("./UCI HAR Dataset/train/X_train.txt")
test <- read.table("./UCI HAR Dataset/test/X_test.txt")
trainlab <- read.table("./UCI HAR Dataset/train/y_train.txt")
testlab <- read.table("./UCI HAR Dataset/test/y_test.txt")
testsubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
trainsubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# column bind labels and subjects with training and test data sets; row bind the two data sets
test <- cbind(testlab, testsubject, test)
train <- cbind(trainlab, trainsubject, train)
mgdata <- rbind(train, test)

# read features and create a vector of column descriptions
features <- read.table("./UCI HAR Dataset/features.txt")
featureschr <- as.character(features[,2])
cols <- vector("character", length(featureschr)+2)
cols[-(1:2)] <- featureschr
cols[1:2] <- c("label", "subject")
names(mgdata) <- cols

# set index of mean and std; select mean and std measurements
meanstdind <- which(grepl("mean[\\()]", cols)|grepl("std[\\()]", cols))
meanstddat <- mgdata[, c(1, 2, meanstdind)]

# replace label with descriptive activity names on mean std data set
activitylab <- read.table("./UCI HAR Dataset/activity_labels.txt")
names(activitylab) <- c("label", "activity")
if (!is.numeric(activitylab$label)) {
    as.numeric(activitylab$label)
}
for (i in 1:length(activitylab$activity)) {
    idx <- which(meanstddat$label == i)
    meanstddat$label[idx] <- sub(i, activitylab[activitylab$label==i,2],meanstddat$label[idx])
}
library(dplyr); meanstddat <- dplyr::rename(meanstddat, activity = label)

# reshape mean std data and split variable names into features, stat, and axis
cols2 <- names(meanstddat); library(reshape2)
mtmeanstddat <- melt(meanstddat, id = c("activity", "subject"), measure.vars = cols2[-(1:2)])
splitvar <- strsplit(as.character(mtmeanstddat$variable), "\\-")
firstElement <- function(x) {x[1]}
secondElement <- function(x) {x[2]}
thirdElement <- function(x) {x[3]}
features <- unlist(sapply(splitvar, firstElement))
stat <- unlist(sapply(splitvar, secondElement)); stat <- gsub("\\()", "", stat)
axis <- unlist(sapply(splitvar, thirdElement))

# append split variable description; make features variable descriptive
mtmeanstddat <- mtmeanstddat %>% mutate(features = features, stat = stat, axis = axis) %>% select(-variable)
mtmeanstddat$features <- sub("^t","Time", mtmeanstddat$features)
mtmeanstddat$features <- sub("^f","Freq", mtmeanstddat$features)

# create separate independent tidy dataset 
# with the average of each variable for each activity and each subject
avg <- dcast(mtmeanstddat, subject + activity ~ features, mean)
write.table(avg, "AverageData.txt", row.names = FALSE)
