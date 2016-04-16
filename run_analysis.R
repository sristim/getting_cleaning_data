
# ======================================================== 
# SCRIPT CONTAINS FOLLOWING RESPONSIBILITIES/CAPABILITIES
# ========================================================
#
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement.
# 3. Use descriptive activity names to name the activities in the data set
# 4. To label the data set with descriptive activity names appropriately.
# 5. To create a second, independent tidy data set with the average of each variable for each activity   #    and each subject.

# Install required packages if not available
# data.table, reshape2
if (!require("data.table")) {
  install.packages("data.table")
}
require("data.table")

if (!require("reshape2")) {
  install.packages("reshape2")
}
require("reshape2")

SCRIPT_HOME <-"/home/devil/Rstudio/rstudio_home/getting_cleaning_data_assignment/"
setwd(SCRIPT_HOME)

#
#Get activity labels
#
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

#
# read features file
#
features <- read.table("./UCI HAR Dataset/features.txt")[,2]


#
# Extract  mean and standard deviation features with grepl
#
ms_features <- grepl("mean|std", features)

#
# read X_test, y_test and subject_test file
#
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#assign every data of X_test with column name from features
names(X_test) = features

# Extract  mean and standard deviation column names 
X_test = X_test[,ms_features]

# assign activiy_labels to digits in y_label
y_test[,2] = activity_labels[y_test[,1]]

#assign column name
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# same process for train data as done for test data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) = features
X_train = X_train[,ms_features]
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

#
# Merges the training and the test sets to create one data set.
#
merged_data = rbind(test_data, train_data)
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(merged_data), id_labels)
melt_data      = melt(merged_data, id = id_labels, measure.vars = data_labels)

#
# Create independent tidy data set with the average of each variable for each activity and each subject.
#
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy_data, file = "tidy_data_set.txt")

