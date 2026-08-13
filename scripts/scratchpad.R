#load packages
library(tidyverse)
library(pzfx)
library(here)
#import raw data using 'here()' to find project root
raw_data <- read_pzfx(
  here("data/raw/extracted/Final Data for Publication/Fig 4e_Alcohol over time copy.pzfx"),
  table = "Data 1"
)
#print raw dim to verify import
dim(raw_data)
#  ---
  #DATA WRANGLING
#  ---
#preview raw data 
glimpse(raw_data)
#observations:
#- 3 rows, 39 columns (wide data frame)
#- no "NA" values
#- all values <dbl>
#- column: "ROWTITLE" contains timepoints "1, 2, 5" 
#- 38 columns represent indiv mice replicates "VEH_n" & "TBH_n" (where 1<=n<=19)
#- mice columns contain daily alcohol intake (g/kg) data 
#restructure data frame to tidy format 
tidy_data <- raw_data |> 
  pivot_longer(
    cols = -ROWTITLE,
    names_to = "mice_replicates",
    values_to = "alcohol_intake"
  )
#- changes made (tidy format data)
#check for duplicate rows
tidy_data |> 
  distinct()
#observations
#- no duplicate rows
#rename column containing timepoints
tidy_data |> 
  rename(day = ROWTITLE)
#split column "mice_replicates" 
tidy_data |> 
  separate_wider_delim(
    cols = mice_replicates,
    delim = "_",
    names = c("treatment", "mouse_id")
  )
#check if changes were made
print(tidy_data)
#- changes made 
#change variable type to: treatment <fct> & mouse_id <int>
tidy_data |> 
  mutate(
    treatment = as.factor(treatment),
    mouse_id = as.integer(mouse_id)
  )
#check changes
print(tidy_data)
#- changes made 
# ---
# VIS recreation 
# ---
#group and summarize data 
summary_data <- tidy_data |> 
  group_by(day, treatment) |> 
  summarise(
    mean_intake = mean(alcohol_intake),
    sd_intake = sd(alcohol_intake),
    n = n(),
    sem_intake = sd_intake / sqrt(n)
  ) |> 
  ungroup()
#check changes 
print(summary_data)
#- changes made
#replicate figure using summary_data 
ggplot(
  summary_data,
  aes(
      x = as.factor(day),
      y = mean_intake,
      group = treatment,
      fill = treatment,
      color = treatment
  )
) +
  #treatment lines
  geom_line(
    position = position_dodge(.2),
    linewidth = 1 
  ) +
  #SEM error bars
  geom_errorbar(
    aes(
      ymin = mean_intake - sem_intake,
      ymax = mean_intake + sem_intake
    ),
    width = .1,
    position = position_dodge(.2),
    linewidth = .8
  ) + 
  #filled points
  geom_point(
    shape = 21,
    size = 4,
    color = "black",
    stroke = 1,
    position = position_dodge(.2)
  ) +
  #color mapping 
  scale_fill_manual(values = c("VEH" = "white",
                               "TBG" = "steelblue")) +
  scale_color_manual(values = c("VEH" = "black",
                                "TBG" = "steelblue")) +
  #zooming without cut off error bars 
  coord_cartesian(
    ylim = c(0, 15)) +
  scale_y_continuous(
    breaks = seq(0, 15, 5)) +
  #labels 
  labs(
    x = "Days",
    y = "Alcohol Intake (g/kg/day)",
    title = "Recreation of Figure 4e"
  ) +
  theme_classic()
  
#  ---
#  Audit
#  ---
#fit 2-way ANOVA test 
anova_model <- aov(
  alcohol_intake ~ treatment * as.factor(day) +
    Error(as.factor(mouse_id)),
  data = tidy_data 
)
#print model
summary(anova_model)
# ---
# Improved figure 
# ---
#what's wrong with it now?
#- showing only mean SEM at each day means 15+ indiv mice are not seen 
#- dynamite plot means you can't tell the variance from graph 
#- "*" shows there is significance but now how it was found and does not give a number 
#- the time scale is evenly spaced dispite day 5 being 3 units from day 2 
#- when printed grayscale info is lost 
#- colors not compatible for colorblind readers 
#how to fix?

library(stats)
library(broom)

# ---
# IMPROVED FIGURE 
# ___




improved_plot <- ggplot(
  tidy_data,
  aes(
    x = day,
    y = alcohol_intake,
    group = mouse_id,
    color = treatment)
) +
#indiv mice trajectories
  geom_line(alpha = 0.25,
            linewidth = 0.5) +
  geom_point(alpha = 0.35,
             size = 1.8) +
#treatment mean line -use 'summary_data'
  geom_line(
    data = summary_data,
    aes(
      x = day,
      y = mean_intake,
      group = treatment),
    linewidth = 1.3,
    inherit.aes = FALSE
  ) +
#SEM bars -use 'summary_data"
  geom_errorbar(
    data = summary_data,
    aes(
      x = day,
      ymin = mean_intake - sem_intake,
      ymax = mean_intake + sem_intake),
    width = 0.15,
    linewidth = 0.9,
    inherit.aes = FALSE
  ) +
#treatment mean points -use 'summary_data''
  geom_point(
    data = summary_data,
    aes(
      x = day,
      y = mean_intake,
      fill = treatment),
    shape = 21,
    size = 4,
    color = "black",
    stroke = 1.1,
    inherit.aes = FALSE
  ) +
#split into one panel per treatment to reduce clutter
  facet_wrap(~ treatment) +
#colorblind-safe palette
  scale_color_viridis_d(end = 0.7) +
  scale_fill_viridis_d(end = 0.7) +
#zoom without dropping data
  coord_cartesian(ylim = c(0, 15)) +
#true day labels
  scale_x_continuous(breaks =
                       c(1, 2, 5),
                     labels =
                       c("Day 1", "Day 2", "Day 5")) +
  scale_y_continuous(breaks =
                       seq(0, 15, 5)) +
  labs(
    x = "Timeline",
    y = "Alcohol Intake (g/kg/day)",
    title = "High-Density Visual Makeover of Figure 4e",
    subtitle = "Individual biological trajectories overlaid with treatment means ± SEM"
  ) +
  theme_classic() +
  theme(
#no legend needed
    legend.position = "none",
    strip.text = element_text(face = "bold",
                              size = 11),
    plot.title = element_text(face = "bold",
                              size = 12),
    plot.subtitle = element_text(size = 9,
                                 color = "grey30")
  )
improved_plot









#___________________________________________
ggplot(
  tidy_data, 
  aes(
    x = day,
    y = alcohol_intake,
    group = mouse_id,
    color = treatment,
    fill = treatment
  )
) +
  geom_point(
      alpha = .3) + 
  geom_line(
    alpha = .15
  )
#--------------------------------
improved_plot <- ggplot(
  tidy_data,
  aes(x = day, y = alcohol_intake, group = mouse_id, color = treatment)
) +
  geom_line(alpha = 0.25, linewidth = 0.5) +
  geom_point(alpha = 0.35, size = 1.8) +
  geom_line(
    data = summary_data,
    aes(x = day, y = mean_intake, group = treatment),
    linewidth = 1.3,
    inherit.aes = FALSE
  ) +
  geom_errorbar(
    data = summary_data,
    aes(x = day, ymin = mean_intake - sem_intake, ymax = mean_intake + sem_intake),
    width = 0.15,
    linewidth = 0.9,
    inherit.aes = FALSE
  ) +
  geom_point(
    data = summary_data,
    aes(x = day, y = mean_intake, fill = treatment),
    shape = 21, size = 4, color = "black", stroke = 1.1,
    inherit.aes = FALSE
  ) +
  facet_wrap(~ treatment) +
  scale_color_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  scale_fill_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  coord_cartesian(ylim = c(0, 15)) +
  scale_x_continuous(breaks = c(1, 2, 5), labels = c("Day 1", "Day 2", "Day 5")) +
  scale_y_continuous(breaks = seq(0, 15, 5)) +
  labs(
    x = "Timeline",
    y = "Alcohol Intake (g/kg/day)",
    title = "High-Density Visual Makeover of Figure 4e",
    subtitle = "Individual biological trajectories overlaid with treatment means ± SEM"
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 11),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 9, color = "grey30")
  )

print(improved_plot)
#-----------------------------------------------------
improved_plot <- ggplot(
  tidy_data,
  aes(x = treatment, y = alcohol_intake, fill = treatment, color = treatment)
) +
  geom_violin(alpha = 0.25, linewidth = 0.4, trim = FALSE) +
  geom_jitter(width = 0.1, alpha = 0.5, size = 1.8) +
  geom_point(
    data = summary_data,
    aes(x = treatment, y = mean_intake),
    shape = 21, size = 4, color = "black", stroke = 1.1,
    inherit.aes = FALSE
  ) +
  geom_errorbar(
    data = summary_data,
    aes(x = treatment, ymin = mean_intake - sem_intake, ymax = mean_intake + sem_intake),
    width = 0.1,
    linewidth = 0.9,
    inherit.aes = FALSE
  ) +
  facet_wrap(~ day, labeller = as_labeller(c(`1` = "Day 1", `2` = "Day 2", `5` = "Day 5"))) +
  scale_color_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  scale_fill_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  coord_cartesian(ylim = c(0, 15)) +
  scale_y_continuous(breaks = seq(0, 15, 5)) +
  labs(
    x = NULL,
    y = "Alcohol Intake (g/kg/day)",
    title = "High-Density Visual Makeover of Figure 4e",
    subtitle = "Distribution and individual mice per day, with treatment means ± SEM"
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 11),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 9, color = "grey30")
  )

print(improved_plot)
#-----------------------------------------------------------------
improved_plot <- ggplot(
  tidy_data,
  aes(x = day, y = alcohol_intake, group = mouse_id)
) +
  geom_line(color = "grey70", alpha = 0.4, linewidth = 0.4) +
  geom_point(color = "grey70", alpha = 0.4, size = 1.5) +
  geom_line(
    data = summary_data,
    aes(x = day, y = mean_intake, group = treatment, color = treatment),
    linewidth = 1.3,
    inherit.aes = FALSE
  ) +
  geom_errorbar(
    data = summary_data,
    aes(x = day, ymin = mean_intake - sem_intake, ymax = mean_intake + sem_intake, color = treatment),
    width = 0.15,
    linewidth = 0.9,
    inherit.aes = FALSE
  ) +
  geom_point(
    data = summary_data,
    aes(x = day, y = mean_intake, fill = treatment),
    shape = 21, size = 4, color = "black", stroke = 1.1,
    inherit.aes = FALSE
  ) +
  scale_color_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  scale_fill_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  coord_cartesian(ylim = c(0, 15)) +
  scale_x_continuous(breaks = c(1, 2, 5), labels = c("Day 1", "Day 2", "Day 5")) +
  scale_y_continuous(breaks = seq(0, 15, 5)) +
  labs(
    x = "Timeline",
    y = "Alcohol Intake (g/kg/day)",
    title = "High-Density Visual Makeover of Figure 4e",
    subtitle = "Individual mouse trajectories (grey) with treatment means ± SEM"
  ) +
  theme_classic() +
  theme(
    legend.position = c(0.85, 0.2),
    legend.title = element_blank(),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 9, color = "grey30")
  )

improved_plot
#----------------------------------
improved_plot <- ggplot(
  tidy_data,
  aes(x = as.factor(day), y = alcohol_intake, fill = treatment, color = treatment)
) +
  geom_violin(alpha = 0.25, linewidth = 0.4, trim = FALSE) +
  geom_jitter(width = 0.08, alpha = 0.4, size = 1.5) +
  geom_line(
    data = summary_data,
    aes(x = as.factor(day), y = mean_intake, group = treatment),
    linewidth = 1.2,
    inherit.aes = FALSE,
    color = "black"
  ) +
  geom_errorbar(
    data = summary_data,
    aes(x = as.factor(day), ymin = mean_intake - sem_intake, ymax = mean_intake + sem_intake),
    width = 0.1,
    linewidth = 0.8,
    inherit.aes = FALSE
  ) +
  geom_point(
    data = summary_data,
    aes(x = as.factor(day), y = mean_intake, fill = treatment),
    shape = 21, size = 4, color = "black", stroke = 1.1,
    inherit.aes = FALSE
  ) +
  facet_wrap(~ treatment) +
  scale_color_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  scale_fill_manual(values = c(VEH = "#D55E00", TBG = "#0072B2")) +
  coord_cartesian(ylim = c(0, 15)) +
  scale_x_discrete(labels = c("Day 1", "Day 2", "Day 5")) +
  scale_y_continuous(breaks = seq(0, 15, 5)) +
  labs(
    x = NULL,
    y = "Alcohol Intake (g/kg/day)",
    title = "High-Density Visual Makeover of Figure 4e",
    subtitle = "Distribution and individual mice per day, with treatment means ± SEM trend"
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 11),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 9, color = "grey30")
  )

improved_plot

