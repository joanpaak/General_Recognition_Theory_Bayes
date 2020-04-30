#include /bivariate_cdf.stan

data{
  int<lower = 0> cMat[4, 4];
  int<lower = -1, upper =1> xMat[4, 2];
  
  real prior_mu_mu[4,2];
  real<lower = 0> prior_mu_sd[4,2];
  
  real prior_rho_mu;
  real<lower = 0> prior_rho_sd;
}

parameters{
  real mu[4,2];  
  real atanh_rho;
}

model{

  matrix[4,4] p;

  atanh_rho ~ normal(prior_rho_mu, prior_rho_sd);
  
  for(i in 1:4){
    for(j in 1:2){
      mu[i,j] ~ normal(prior_mu_mu[i,j], prior_mu_sd[i,j]);
    }
  }
  
  for(i in 1:4){
    for(j in 1:4){
      p[i,j] = 
      log(bivariate_cdf(xMat[j,1] * mu[i,1], 
                        xMat[j,2] * mu[i,2], 
                        xMat[j,1] * xMat[j,2] * tanh(atanh_rho))) * cMat[i,j];
    }
  }
  
  target += sum(p);
}
