## README
***  
This project assignment has been carried out to review the process of getting and cleaning data in R on *Human Activity Recognition Using Smartphones Dataset (Version 1.0)* downloaded from the following link:

<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

There are four files in this repository:  
* README.md  
* Code Book.md  
* run_analysis.R  
* AverageData.csv  

The R script starts with downloading the zip file from the website which is provided on the assignment instructions, followed by an unzipping step which creates a repository named **"UCI HAR Dataset"** where all raw data files have been stored.

The **X file** which contains the measurement data, the **y file** which contains the labels of activities experimented, and the **subject** file, respectively for both **training** and **test** data sets, are read into R using `read.table` function and stored as data frames.

The next part of the script uses `cbind` and `rbind` functions combining all the six data frames mentioned above into one single data frame with **labels** and **subjects** appended so that each observation is identifiable.

Up to this point, the **merged data** still exists without meaningful column names. This step reads in **features file** and extracts the second column which denotes the column names of **merged data** as a character vector with two additional elements at the start for **"label"** and **"subject"** columns. Then this column name vector is assigned to the column names of **merged data**.

As part of the requirements of this assignment, this step subsets **mean** and **standard deviation** measurements which are denoted as **mean()** and **std()** in the column names. Then the values in **"label"** column are replaced with the **activity** descriptions from the second column in **activity labels** file using matching up process with index of **activity labels**. The **"label"** has also been renamed as **"activity"**.

The script comes to the stage of reshaping data. First the column names are stored in **cols2** vector for the reshaping process to be able to identify the columns with correct column names. The **mean and standard deviation data set** is melted with **"activity"** and **"subject"** as its ID variables, so it turns into a long and narrow data frame with each measurement sitting as its own row. After that, the measurement descriptions of **"variable"** column in the melted data are split into 3 different parts which are extracted and stored in three character vectors -- **features**, **statistics**, and **axes**. 

These three vectors are mutated to the **melted mean std data frame**, so that different rows of same feature could be grouped and summarised with **average values** for each measurement within `dcast` step, which lays the features horizontally so that each measurement sits in one column and the combination of **subjects** and **activities** vertically as different observations.

The scripts ends with exporting the final independent tidy data set as **"AverageData.csv"** file in the working directory.
