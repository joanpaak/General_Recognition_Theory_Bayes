# Functions for plotting the posterior

plotMus = function(stanfit, xlab = "Dimension 1", 
                   ylab = "Dimension 2", alpha = 0.05,
                   n_to_draw = 1000){
  
  # Used for drawing posterior distributions of the mu parameters
  # of the latent distributions. 
  #
  # INPUT:
  # stanfit = obviously, a stanfit object, containing samples from
  #           one of the models specified in this project.
  #
  # xlab, ylab = labels to draw for the axes
  #
  # alpha = transparency of a single posterior draw. The more posterior
  #         draws you intend to plot, the more transparent they probably
  #         should be
  #
  # n_to_draw = how many posterior draws to draw
  #

  mu_mat = extract(stanfit, pars = "mu")[[1]]
  
  if(nrow(mu_mat) < n_to_draw){
    warning(paste("Tried to draw", n_to_draw, "posterior samples, but only", 
                  nrow(mu_mat), "samples found"))
    n_to_draw = nrow(mu_mat)
  }
  
  mu_mat = mu_mat[1:n_to_draw,,]
  
  plot(NULL, xlim = range(mu_mat[,,1]), ylim = range(mu_mat[,,2]),
       axes = F, xlab = xlab, ylab = ylab)
  
  axis(side = 1); axis(side = 2)
  abline(h = 0, lty = 2, lwd = 1.2); abline(v = 0, lty = 2, lwd = 1.2)
  
  abline(h = pretty(range(mu_mat[,,1])), lty = 3, col = rgb(0, 0, 0, 0.7))
  abline(v = pretty(range(mu_mat[,,2])), lty = 3, col = rgb(0, 0, 0, 0.7))
  
  for(i in 1:4) {
    points(mu_mat[,i,1], mu_mat[,i,2], pch = 19, col = rgb(0, 0, 0, alpha))
  }
}

#

plotRhos = function(stanfit, maintitles = c()){
  
  # Simply draws histograms of the marginal posterior distributions
  # for the four correlation coefficients. 
  # IMPORTANT NOTE: the samples are assumed to be atanh transformed, the
  # inverse transform is applied to them inside this function!
  #
  # INPUT: 
  # stanfit = obviously, a stanfit object, containing samples from
  #           one of the models specified in this project.
  #
  # maintitles = titles for the graphs. Should be in the same order
  #              as the stimuli are. E.g. c("low, short", "low, long" etc...)
  
  rho_mat = extract(stanfit, pars = "atanh_rho")[[1]]
  
  original_mfrow = par()$mfrow

  par(mfrow = c(2, 2))

  for(i in 1:4) {
    hist(tanh(rho_mat[,i]), 
         main = maintitles[i], 
         prob = T, xlab = expression(rho), ylab = "Density")
  }

  par(mfrow = original_mfrow)
  
}

