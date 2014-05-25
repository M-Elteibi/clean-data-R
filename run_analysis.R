library(plyr)
#URL of the file
source_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file_name <- "getdata_projectfiles_UCI_Dataset.zip"
# Check for a data directory otherwise create it
if (!file.exists("data")) {
    dir.create("data")
}

#folder to save the file
dest_fold <- "data"

#download the file
download.file(source_url , destfile = paste0(dest_fold,"/",file_name) , method = "curl")

# since file is a zip file need to extract it's contents
# Also retain the info on all extracted files
extracts <- unzip(paste0(dest_fold,"/",file_name) , list = T , exdir = dest_fold)
unzip(paste0(dest_fold,"/",file_name) , list = F , exdir = dest_fold)

# Reference Data needed for both Train and test datsets
ref_loc <- paste0(dest_fold,"/UCI HAR Dataset/")
act_ref <- read.table(paste0(ref_loc,"activity_labels.txt"), header=F, col.names=c("id", "activity"))
feat_ref <- read.table(paste0(ref_loc,"features.txt"), header=F, col.names=c("id", "feature"))


# Training Data prep
# Here need to add the Subject and activity identifiers onto the measurement
# Also need to rename the variables and recode the activities to the actual name of the activity
train_loc <- paste0(ref_loc,"train/")
train_col_names <- feat_ref[,2]
x_train <- read.table(paste0(train_loc,"X_train.txt"), header=F, col.names = train_col_names)

subj_train <- read.table(paste0(train_loc,"subject_train.txt"), header=F, col.names = "subject")
y_train <- read.table(paste0(train_loc,"y_train.txt"), header=F, col.names = "id")

y_act <- merge(y_train, act_ref, by.x = "id", by.y= "id" )
names(y_act) <- c("activity_id", "activity_name")

# can use this to confirm the merge is correct xtabs(~ id + activity, data = y_act)
all_train <- data.frame(subj_train , y_act$activity_name , x_train)
names(all_train) <- c(names(subj_train), "activity_name" , names(x_train))


# Test Data prep
# Here need to add the Sugject and activity identifiers onto the measurement
# Also need to rename the variables and recode the activities to the actual name of the activity
test_loc <- paste0(ref_loc,"test/")
test_col_names <- feat_ref[,2]
x_test <- read.table(paste0(test_loc,"X_test.txt"), header=F, col.names = test_col_names)

subj_test <- read.table(paste0(test_loc,"subject_test.txt"), header=F, col.names = "subject")
y_test <- read.table(paste0(test_loc,"y_test.txt"), header=F, col.names = "id")

y_act_test <- merge(y_test, act_ref, by.x = "id", by.y= "id" )
names(y_act_test) <- c("activity_id", "activity_name")

# can use this to confirm the merge is correct xtabs(~ id + activity, data = y_act)
all_test <- data.frame(subj_test , y_act_test$activity_name , x_test)
names(all_test) <- c(names(subj_test), "activity_name" , names(x_test))


# Combine Train and Test all sets
# First requirement
all_comb <- rbind(all_train , all_test)


# Now all are combined we need to keep only mean and standard deviation measurement columns 
# plus the activity and subject ID
# to do this will create a logical vector
# from reading the features_info.txt file mean and sd are named with .mean. and .sd. will use this
# in a regular expression to create a logical vector that looks for these paterns plus 
# the subject and activity
search_exp <- "(\\.mean\\.)|(\\.std\\.)|(subject)|(activity_name)"
req_data <- all_comb[,grepl(search_exp , names(all_comb) )]

# Now fix up the names of the variables as follows
# replace ... with .
# remove .. do not replace with anything these happen at the end only
names(req_data) <- tolower(gsub("\\_","\\.", gsub("\\.\\.","",gsub("\\.\\.\\.", "\\." , names(req_data)))))
#summary(req_data$activity.name)


summ_set <- aggregate(req_data[,3:ncol(req_data)] , req_data[,1:2] , FUN = mean , na.rm = T)

#export summary data for upload
write.table(summ_set, "./summary_data.txt" , row.names=F )
