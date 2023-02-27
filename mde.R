alpha_2 <- 0.975

t_alpha_2 <- qnorm(p = alpha_2)

t_kappa_c_plugged <- (0.0114/0.00671) - t_alpha_2

pnorm(q = t_kappa_c_plugged)

alpha_2 <- 0.975 # 2,5% for each side (bicaudal)
kappa <- 0.80

t_alpha_2 <- qnorm(p = alpha_2) # Returns the critical value in a normal distribution for a probability of alpha_2
t_kappa_c <- qnorm(p = kappa) # We use kappa instead of 1-kappa because by default qnorm uses P[X <= x], if we used 1-kappa we would have to set lower.tail = F

(mde1 = (t_alpha_2 + t_kappa_c)*0.00671)


readxl::read_excel()
