 # Load Libraries
 library(pzfx)
 library(dplyr)
 library(tidyr)
 library(readr)

 # Safe Short Paths to Avoid Wrapping
  base_dir  <- "C:/Users/Isaac/Projects/Tabernanthalog_Audit"
 sub_fold  <- "data/raw/extracted/Final Data for Publication"
  file_name <- "Fig 4e_Alcohol over time copy.pzfx"
 
  # Combine them safely
  raw_file <- file.path(base_dir, sub_fold, file_name)
  out_dir  <- file.path(base_dir, "data/processed")
 
 # Create Folder
 if (!dir.exists(out_dir)) {
     dir.create(out_dir, recursive = TRUE)
   }

 # Import Data
 raw_data <- read_pzfx(raw_file, table = "Data 1")

 # Tidy Wide to Long
 tidy_data <- raw_data |>
     rename(Day = ROWTITLE) |>
     mutate(Day = as.numeric(Day)) |>
     pivot_longer(
         cols = -Day,
         names_to = "Mouse_Key",
         values_to = "Alcohol_Intake"
       ) |>
     separate_wider_delim(
         cols = Mouse_Key,
         delim = "_",
         names = c("Treatment", "Mouse_ID")
       ) |>
     mutate(
         Treatment = as.factor(Treatment),
         Mouse_ID  = as.integer(Mouse_ID)
       ) |>
     arrange(Treatment, Mouse_ID, Day)

 # Show Tidy Dimensions
 print(dim(tidy_data))

 # Show First 10 Rows
 print(head(tidy_data, 10))

 # Save Clean Data
 out_file <- file.path(out_dir, "tidy_alcohol_consumption.csv")
 write_csv(tidy_data, out_file)
 
 
