The first function in the file, "make_means" is what you want to run to get the tidy data set.
It first makes a data set combining the test and train data sets and keeping only columns with mean() or std() in the name.

This leaves about 10k rows in 68 columns, 2 of which are the subject and the activity name.  See the script file for details on how this is done.

Once the combined test and train data set is available, make_means creates a data.frame 180x68 large, with the last two columns being the activity name and subject.  For each unique pair of these (each row), a SQL query picks out the records that match them and the mean is computed.  This is the least efficient piece, and takes the longest.


The final output is 68 columns, in the same order as the original features.txt file, but with only columns that have mean() or std() in the name.  The two rightmost columns are the activity name and the subject.
