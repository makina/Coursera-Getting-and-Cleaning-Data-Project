## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load activity_labels
a_lbls <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load column_names
f <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract mean and standard deviation
ext_f <- grepl("mean|std", f)

# Load X_test y_test & subject_test
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = f

# Extract mean and standard deviation
X_test = X_test[,ext_f]

# Load activity labels
y_test[,2] = a_lbls[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = f

# Extract mean and standard deviation
X_train = X_train[,ext_f]

# Load activity_label
y_train[,2] = a_lbls[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data
data = rbind(test_data, train_data)

id_lbls   = c("subject", "Activity_ID", "Activity_Label")
data_lbls = setdiff(colnames(data), id_lbls)
melt_data = melt(data, id = id_lbls, measure.vars = data_lbls)

# Apply mean function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt",row.name=FALSE)