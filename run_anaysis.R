# Loading packages and data sets
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Load activity labels + features
activity_labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
req_features <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- gsub('[()]', '', features[req_features, featureNames])

# Load train datasets
x_train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, req_features, with = FALSE]
data.table::setnames(x_train, colnames(x_train), measurements)
y_train <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                       , col.names = c("Activity"))
subject_train <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(subject_train, y_train, x_train)

# Load test datasets
x_test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, req_features, with = FALSE]
data.table::setnames(x_test, colnames(x_test), measurements)
y_test <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
subject_test <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(subject_test, y_test, x_test)

# merge datasets
merged <- rbind(train, test)

# Convert classLabels to activityName basically. More explicit. 
merged[["Activity"]] <- factor(merged[, Activity]
                              , levels = activity_labels[["classLabels"]]
                              , labels = activity_labels[["activityName"]])

merged[["SubjectNum"]] <- as.factor(merged[, SubjectNum])
merged <- reshape2::melt(data = merged, id = c("SubjectNum", "Activity"))
merged <- reshape2::dcast(data = merged, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = merged, file = "tidy_data.txt", quote = FALSE)
