The first function in the file, "make_means" is what you want to run to get the tidy data set.
It first makes a data set combining the test and train data sets and keeping only columns with mean() or std() in the name.

This leaves about 10k rows in 68 columns, 2 of which are the subject and the activity name.  See the script file for details on how this is done.

Once the combined test and train data set is available, make_means creates a data.frame 180x68 large, with the last two columns being the activity name and subject.  For each unique pair of these (each row), a SQL query picks out the records that match them and the mean is computed.  This is the least efficient piece, and takes the longest.


The final output is 68 columns, in the same order as the original features.txt file, but with only columns that have mean() or std() in the name.  The two rightmost columns are the activity name and the subject.

The entire process in detail:

1) Call make_means() with the directory of your data

make_means() calls combine_data() described below.  It then makes a data.frame called means_data with 68 columns whose names are exactly the same as those returned from combine_data(), call that one original_data.  Each row has a unique (activity_name, subject) pair, so there are 180 rows in means_data.  For each such pair, all rows matching this pair are selected from original_data.  Some of these are empty, some are not.  For each of the first 66 columns in this selection, compute the mean and throw it in the corresponding row and column of means_data.
That's it.

combine_data()
Calls get_data_test() and get_data_train().  These are identical except the first gets test data, and the other gets training data.  Since they're essentially the same, only one is described.
Having each, they're row bound to create a big data.frame of 68 columns and about 10,000 rows.
 
get_data_test()
1) load features.txt keeping only the second column.  These are the column names to be used for the data set.
2) Pick out only the names that have mean() or std() in them.  That makes 66 column names.
3) read activity_labels.txt, this is a table of activity numbers and associated names.
4) reach the X_train.txt file, but only keep the columns found in step 2.
5) Add a list of activity names as the right most column
6) Add a list of subjects as the right most column
7) Return the resulting 68 columns
