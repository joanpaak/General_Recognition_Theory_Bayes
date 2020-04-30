setwd("C:/Users/Joni/Documents/GitHub/Generalized_Recognition_Theory_Bayes/R/silbert09a/")

#### Load libraries, compile models etc. #### 

library(mdsdt)
library(rstan)

data("silbert09a")

mdl2x2_one_rho   = stan_model("../../Stan/mdl2x2_one_rho.stan")
mdl2x2_four_rhos = stan_model("../../Stan/mdl2x2_four_rhos.stan")

## The matrix defining the order of stimuli and responses, this is same for both of the models:

xMat = matrix(c(-1,-1, 
                -1, 1,
                 1,-1,
                 1, 1), ncol = 2, nrow = 4, byrow = T)

#
# Priors for both models are uninformative. The priors for the mus are set 
# a bit apart from each other, implying discriminability, but the standard
# deviations are high. Prior for correlation coefficients is centered at 
# zero, but theres's quite a bit of standard deviation there too (remember
# that the prior  is defined on the atanh transformed scale!)

#### 2x2 one rho ####

prior_mu_mu = matrix(c(-1, -1, 
                       -1,  1,  
                        1, -1,
                        1,  1), ncol  = 2, nrow = 4, byrow = T)

prior_mu_sd = matrix(c(10, 10, 
                       10, 10,  
                       10, 10,
                       10, 10), ncol  = 2, nrow = 4, byrow = T)

prior_rho_mu = 0
prior_rho_sd = 0.20

data_for_stan = list(prior_mu_mu = prior_mu_mu, 
                     prior_mu_sd = prior_mu_sd,
                     prior_rho_mu = prior_rho_mu,
                     prior_rho_sd = prior_rho_sd,
                     xMat = xMat,
                     cMat = silbert09a)


# Uses two cores for parallel processing:
options(mc.cores = 2)

fit_one_rho = sampling(mdl2x2_one_rho, data = data_for_stan,
                         chains = 4, iter = 1000)

#### 2x2 four rhos ####


prior_mu_mu = matrix(c(-1, -1, 
                       -1,  1,  
                        1, -1,
                        1,  1), ncol  = 2, nrow = 4, byrow = T)

prior_mu_sd = matrix(c(10, 10, 
                       10, 10,  
                       10, 10,
                       10, 10), ncol  = 2, nrow = 4, byrow = T)


prior_rho_mu = c(0.0, 0.0, 0.0, 0.0)
prior_rho_sd = c(0.20, 0.20, 0.20, 0.20);

data_for_stan = list(prior_mu_mu = prior_mu_mu, 
                     prior_mu_sd = prior_mu_sd,
                     prior_rho_mu = prior_rho_mu,
                     prior_rho_sd = prior_rho_sd,
                     xMat = xMat,
                     cMat = silbert09a)


# Uses two cores for parallel processing:
options(mc.cores = 2)

fit_four_rhos = sampling(mdl2x2_four_rhos, data = data_for_stan,
                         chains = 4, iter = 2000)


##### Plots plots plots #####

source("../plotting_functions.R")

plotMus(fit_four_rhos, xlab = "Pitch", ylab = "Length")
plotRhos(fit_four_rhos, rownames(silbert09a))

# write figures to files:
#
png(filename = "one_rho_mus.png"); plotMus(fit_four_rhos, xlab = "Pitch", ylab = "Length"); dev.off()
png(filename = "one_rho_rho.png")
hist(tanh(extract(fit_one_rho, pars = "atanh_rho")[[1]]), prob = T, main = "", xlab = expression(rho))
dev.off()

png(filename = "four_rhos_mus.png"); plotMus(fit_four_rhos, xlab = "Pitch", ylab = "Length"); dev.off()
png(filename = "four_rhos_rhos.png"); plotRhos(fit_four_rhos, rownames(silbert09a)); dev.off()

