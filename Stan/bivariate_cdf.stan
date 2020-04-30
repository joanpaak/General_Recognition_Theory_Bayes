// SOURCES:
// Boys, R.J. (1989): Algorithm AS R80: A Remark on Algorithm AS 76: An Integral Useful 
//   in Calculating Noncentral t and Bivariate Normal Probabilities.  Journal of the Royal 
//   Statistical Society. Series C (Applied Statistics), Vol. 38, No. 3, pp. 580-582.
// Pan, K. (2017): An Analytical Expression for Bivariate Normal Distribution.  https://ssrn.com/abstract=2924071

functions {
  real bivariate_cdf(real h, real k, real rho) {
    real p;
    //real h_;
    //real k_;
    real a1;
    real a2;
    real denominator;
    real deltacoeff;
    
    if(h != 0 || k != 0){
      // The point of this is to get rid of sign in 
      // the zero, if there is one. I.e. change -0 to 0.
      
      real h_ = h == 0 ? 0 : h;
      real k_ = k == 0 ? 0 : k;
      
      // These ratios (between k and h) are the wrong 
      // way round in the paper
      denominator = sqrt(1 - rho * rho);
      a1 = (k_/h_ - rho) / denominator;
      a2 = (h_/k_ - rho) / denominator;
      
      // The a-parameter is limited between (-1e6, 1e6), 
      // so that the gradients don't "blow up":
      
      if(a1 > 1e6){
        a1 = 1e6;
      }
      else if(a1 < -1e6){
        a1 = -1e6;
      }
      
      if(a2 > 1e6){
        a2 = 1e6;
      }
      else if(a2 < -1e6){
        a1 = -1e6;
      }
      
    // 
      
      if((h_ * k_) > 0 || (h_ * k_) == 0 && (h_ + k_) >= 0){
        deltacoeff = 0.0;
      } else{
        deltacoeff = 1.0;
      }
      
      p = 0.5 * (Phi(h_) + Phi(k_) - deltacoeff) - owens_t(h_,  a1) - owens_t(k_, a2);
    } else{
      // From the Pan's paper, eq. 10:
      p = 0.1591549 * asin(rho) + 0.25;
    }
    
    if(p < 0){
      // Since a is limited, the approximated integral will
      // sometimes be slightly negative. But not much! Don't worry!
      //print("P was lower than 0: ", p);
      p = 0;
    }
    return p;
  }    
}
