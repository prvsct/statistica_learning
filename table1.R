# This replicates table1_and_A1.do

# Cleans the envinroment
rm(list=ls())

# Loads main packages
library(tidyverse)
library(tidylog)

# ----- PANEL A 1-3 ----

# Loads data
elearn_balance_data <- haven::read_dta("data/Elearn/elearn_balance_data.dta")

# Columns 1 and 2
table1_panelA_columns12 <- elearn_balance_data %>% 
  group_by(treatment) %>% 
  summarise(
    across(
      c(
        z_score_total_bl,
        age_bl,
        attendance_bl,
        computer_yn_bl,
        m_ed_noschool,
        f_ed_noschool
      ),
      list(mean = ~ mean(.x, na.rm=T), sd = ~ sd(.x, na.rm=T))
    )
  ) %>% 
  pivot_longer(cols = -treatment, names_to = "var", values_to = "value")

# Column 3
table1_panelA_column3_models <- elearn_balance_data %>% 
  filter(child_interviewed_bl==1) %>% 
  select(
    school_code,
    treatment,
    z_score_total_bl,
    age_bl,
    attendance_bl,
    computer_yn_bl,
    m_ed_noschool,
    f_ed_noschool
  ) %>% 
  pivot_longer(c(-school_code, -treatment), names_to = "variable", values_to = "value") %>% 
  group_by(variable) %>% 
  nest() %>% 
  mutate(
    model = purrr::map(data,
                       ~ estimatr::lm_robust(
                         data = .,
                         formula = value ~ treatment,
                         cluster = school_code,
                         se_type = "stata"))
  )

table1_panelA_column3 <- cbind(table1_panelA_column3_models$variable,
                               purrr::map_dfr(.x = table1_panelA_column3_models$model, .f = broom::tidy) %>% filter(term=="treatment")
                               ) %>% 
  select(-term,-outcome)

# ---- PANEL C COLUMNS 1-3 ----

table1_panelC_columns12 <- elearn_balance_data %>% 
  filter(uni_sch==1) %>% 
  group_by(treatment) %>% 
  summarise(
    across(
      c(
        totenroll8_bl,
        sections8_bl,
        school_computerlab_bl
      ),
      list(mean = ~ mean(.x, na.rm=T), sd = ~ sd(.x, na.rm=T))
    )
  ) %>% 
  pivot_longer(cols = -treatment, names_to = "var", values_to = "value")

# Column 3
table1_panelC_column3_models <- elearn_balance_data %>% 
  filter(uni_sch==1) %>%
  select(
    school_code,
    treatment,
    totenroll8_bl,
    sections8_bl,
    school_computerlab_bl
  ) %>% 
  pivot_longer(c(-school_code, -treatment), names_to = "variable", values_to = "value") %>% 
  group_by(variable) %>% 
  nest() %>% 
  mutate(
    model = purrr::map(data,
                       ~ estimatr::lm_robust(
                         data = .,
                         formula = value ~ treatment,
                         cluster = school_code,
                         se_type = "stata"))
  )

table1_panelC_column3 <- cbind(table1_panelC_column3_models$variable,
                               purrr::map_dfr(.x = table1_panelC_column3_models$model, .f = broom::tidy) %>% filter(term=="treatment")
) %>% 
  select(-term,-outcome)

# ---- PANEL B COLUMNS 1-3 ----

# Loads data
elearn_balance_data <- haven::read_dta("data/Elearn/elearn_teacher_balance.dta")

# Columns 1 and 2
table1_panelB_columns12 <- elearn_balance_data %>% 
  group_by(treatmentschool) %>% 
  summarise(
    across(
      c(
        t_teachereduc_masters_bl,
        t_tenure_total_bl,
        t_preptime_bl,
        t_usetech_class_bl,
        t_usetech_prep_bl
      ),
      list(mean = ~ mean(.x, na.rm=T), sd = ~ sd(.x, na.rm=T))
    )
  ) %>% 
  pivot_longer(cols = c(-treatmentschool), names_to = "var", values_to = "value")

# Column 3
table1_panelB_column3_models <- elearn_balance_data %>% 
  select(
    school_code,
    treatmentschool,
    t_teachereduc_masters_bl,
    t_tenure_total_bl,
    t_preptime_bl,
    t_usetech_class_bl,
    t_usetech_prep_bl
  ) %>% 
  pivot_longer(c(-treatmentschool,-school_code), names_to = "variable", values_to = "value") %>% 
  group_by(variable) %>% 
  nest() %>% 
  mutate(
    model = purrr::map(data,
                       ~ estimatr::lm_robust(
                         data = .,
                         formula = value ~ treatmentschool,
                         cluster = school_code,
                         se_type = "stata"))
  )

table1_panelB_column3 <- cbind(table1_panelB_column3_models$variable,
                               purrr::map_dfr(.x = table1_panelB_column3_models$model, .f = broom::tidy) %>% filter(term=="treatmentschool")
) %>% 
  select(-term,-outcome)

# ---- PANEL A COLUMNS 4-6 ----

# Loads data
elearn_balance_data <- haven::read_dta("data/Elearn_tablets/elearn_tablets_balance_data.dta")

# Columns 4 and 5
table1_panelA_columns45 <- elearn_balance_data %>% 
  group_by(treatment) %>% 
  summarise(
    across(
      c(
        z_score_total_bl,
        Age,
        Number_of_Days_Student_was_Absen,
        has_a_Computer_in_the_Ho_yn,
        s_Mother_Education_none,
        s_Father_Education_none
      ),
      list(mean = ~ mean(.x, na.rm=T), sd = ~ sd(.x, na.rm=T))
    )
  ) %>% 
  pivot_longer(cols = -treatment, names_to = "var", values_to = "value")

# Column 6
table1_panelA_column45_models <- elearn_balance_data %>% 
  #filter(child_interviewed_bl==1) %>% 
  select(
    school_code,
    treatment,
    z_score_total_bl,
    Age,
    Number_of_Days_Student_was_Absen,
    has_a_Computer_in_the_Ho_yn,
    s_Mother_Education_none,
    s_Father_Education_none
  ) %>% 
  pivot_longer(c(-school_code, -treatment), names_to = "variable", values_to = "value") %>% 
  group_by(variable) %>% 
  nest() %>% 
  mutate(
    model = purrr::map(data,
                       ~ estimatr::lm_robust(
                         data = .,
                         formula = value ~ treatment,
                         cluster = school_code,
                         se_type = "stata"))
  )

table1_panelA_column45 <- cbind(table1_panelA_column45_models$variable,
                               purrr::map_dfr(.x = table1_panelA_column45_models$model, .f = broom::tidy) %>% filter(term=="treatment")
) %>% 
  select(-term,-outcome)

# ---- PANEL C COLUMNS 4-6 ----

# Columns 4 and 5
table1_panelC_columns45 <- elearn_balance_data %>% 
  filter(unisch==1) %>% 
  group_by(treatment) %>% 
  summarise(
    across(
      c(
        school_grade6_sections,
        school_grade6_enrollment,
        school_computerlab
      ),
      list(mean = ~ mean(.x, na.rm=T), sd = ~ sd(.x, na.rm=T))
    )
  ) %>% 
  pivot_longer(cols = -treatment, names_to = "var", values_to = "value")

# Column 3
table1_panelC_column45_models <- elearn_balance_data %>% 
  filter(unisch==1) %>%
  select(
    school_code,
    treatment,
    school_grade6_sections,
    school_grade6_enrollment,
    school_computerlab
  ) %>% 
  pivot_longer(c(-school_code, -treatment), names_to = "variable", values_to = "value") %>% 
  group_by(variable) %>% 
  nest() %>% 
  mutate(
    model = purrr::map(data,
                       ~ estimatr::lm_robust(
                         data = .,
                         formula = value ~ treatment,
                         cluster = school_code,
                         se_type = "stata"))
  )

table1_panelC_column45 <- cbind(table1_panelC_column45_models$variable,
                               purrr::map_dfr(.x = table1_panelC_column45_models$model, .f = broom::tidy) %>% filter(term=="treatment")
) %>% 
  select(-term,-outcome)

# ---- PANEL B COLUMNS 4-6 ----

# Loads data
elearn_balance_data <- haven::read_dta("data/Elearn_tablets/elearn_tablets_teacher_balance.dta")

# Columns 4 and 5
table1_panelB_columns45 <- elearn_balance_data %>% 
  group_by(treatment) %>% 
  summarise(
    across(
      c(
        t_masters,
        t_tenure_total,
        t_preptime,
        t_tech_classes_yn,
        t_tech_prep_yn
      ),
      list(mean = ~ mean(.x, na.rm=T), sd = ~ sd(.x, na.rm=T))
    )
  ) %>% 
  pivot_longer(cols = c(-treatment), names_to = "var", values_to = "value")

# Column 6
table1_panelB_column6_models <- elearn_balance_data %>% 
  select(
    treatment,
    school_code,
    t_masters,
    t_tenure_total,
    t_preptime,
    t_tech_classes_yn,
    t_tech_prep_yn
  ) %>% 
  pivot_longer(c(-treatment,-school_code), names_to = "variable", values_to = "value") %>% 
  group_by(variable) %>% 
  nest() %>% 
  mutate(
    model = purrr::map(data,
                       ~ estimatr::lm_robust(
                         data = .,
                         formula = value ~ treatment,
                         cluster = school_code,
                         se_type = "stata"))
  )

table1_panelB_column6 <- cbind(table1_panelB_column6_models$variable,
                               purrr::map_dfr(.x = table1_panelB_column6_models$model, .f = broom::tidy) %>% filter(term=="treatment")
) %>% 
  select(-term,-outcome)
