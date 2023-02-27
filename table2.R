# This replicates table1_and_A1.do

# Cleans the envinroment
rm(list=ls())

# Loads main packages
library(tidyverse)
library(tidylog)

# Loads data
elearn_reg_data <- haven::read_dta("data/Elearn/elearn_reg_data.dta") %>% 
  rename_with(.cols = starts_with("_"), ~ stringr::str_replace(.x, "_", "v_"))

# ---- Panel A Col 1-4 ----

# Clasrooms
project_classrooms <- elearn_reg_data %>% 
  filter(tooktest_el==1) %>% 
  estimatr::lm_robust(
  formula = z_irt_total_el ~
    treatment +
    v_z_irt_math_bl +
    v_z_irt_sci_bl +
    strataFE1 +
    strataFE2 +
    strataFE3 +
    strataFE4 +
    strataFE5,
  clusters = school_code,
  se_type = "stata"
)

project_clasrooms_group_mean <- elearn_reg_data %>% 
  filter(treatment==0 & tooktest_el==1) %>% 
  summarise(mean = mean(z_irt_total_el, na.rm=T))

# Column 2
pec_classrooms <- elearn_reg_data %>% 
  filter(tooktest_el==1 & took_std==1) %>% 
  estimatr::lm_robust(
    formula = z_scoreindex_el ~
      treatment +
      v_z_irt_math_bl +
      v_z_irt_sci_bl +
      v_meanmath_pec_2016 + 
      v_meansci_pec_2016 + 
      v_meaneng_pec_2016 +
      v_meaneng_pec_2016_mi +
      strataFE1 +
      strataFE2 +
      strataFE3 +
      strataFE4 +
      strataFE5,
    clusters = school_code,
    se_type = "stata"
  )

pec_clasrooms_group_mean <- elearn_reg_data %>% 
  filter(treatment==0 & tooktest_el==1 & took_std==1) %>% 
  summarise(mean = mean(z_scoreindex_el, na.rm=T))

# ---- Panel B Col 1-4 ----

elearn_reg_data_tooktest <- elearn_reg_data %>%
  filter(tooktest_el==1)

elearn_reg_data_lasso_matrix <- elearn_reg_data_tooktest %>%
  select(v_z_irt_math_bl,
         v_z_irt_sci_bl,
         starts_with("strata"),
         starts_with("v_"),
         -strataFE6) %>%
  as.matrix()

cv_model <- glmnet::cv.glmnet(
  x = elearn_reg_data_lasso_matrix,
  y = elearn_reg_data_tooktest %>% pull(z_irt_total_el),
  alpha = 1,
  trace.it = 1,
  relax = T,
  gamma = c(0, 0.25, 0.5, 0.75, 1),
  penalty.factor = c(rep(0, 8), rep(1, 298))
)

plot(cv_model)

cv_model

best_model <- glmnet::glmnet(
  x = elearn_reg_data_lasso_matrix,
  y = elearn_reg_data_tooktest %>% pull(z_irt_total_el),
  lambda = 1.066912e-01,
  alpha = 1,
  penalty.factor = c(rep(0, 7), rep(1, 298)),
  relax = T
)

selected_coef <- as.data.frame(as.matrix(best_model$beta)) %>%
  filter(s0 != 0)

lasso_x <- elearn_reg_data_tooktest %>%
  select(v_z_irt_math_bl,
         v_z_irt_sci_bl,
         starts_with("strata"),
         starts_with("v_")) %>%
  as.matrix()

lasso_y <- elearn_reg_data_tooktest %>% pull(z_irt_total_el) %>% as.matrix()

lasso_d <- elearn_reg_data_tooktest %>% pull(treatment) %>% as.matrix()

lasso <- hdm::rlassoEffect(
  x = lasso_x,
  y = lasso_y,
  d = lasso_d,
  I3 = c(rep(T, 7), rep(F, 298)),
  method = "double selection"
)

lasso$coefficients
