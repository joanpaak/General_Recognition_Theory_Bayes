#Bayesian inference in General Recognition Theory: application to 2x2 categorization experiment

For an introduction to General  Recognition Theory,  the following sources can be recommended:

- Silbert, N.H. & Hawkins, R.X.D. (2016): A tutorial on General Recognition Theory, Journal of Mathematical Psychology, vol. 73, pp. 94 - 109.
- Ashy, F.G. & Soto, F.A. (2015): Multidimensional Signal Detection Theory. In Busemeyer, J. R., Wang, Z., Townsend, J. T. & Eidels, A. (Eds.): The Oxford handbook of computational and mathematical psychology.

Here, I'll be limiting myself to the ubiquitous 2x2 categorization task. In such a task the participant is presented with two-dimensional stimuli; two signal levels are selected fromboth dimensions, hence the 2x2 in the name. The actual task is then to select the correct category for each stimulus. I will assume that anyone reading this  is familiar with that sort of setup. 

## Formatting data for the models:

You will need to provide two pieces of data. A full 4x4 confusion matrix and a matrix defining the order of stimuli and responses in which the first level is coded  with -1 and the second level with 1. 

For exaxmple in the data set silbert09a from the R library mdsdt the stimuli are in the order "low, short", "low, long", "high, short" and "high, long". This would produce the following matrix: 

|    |    |
|----|----|
| -1 | -1 |
| -1 |  1 |
|  1 | -1 |
|  1 |  1 |

(Discard the empty header line: that is just a byproduct of GitHub's markdown). **NOTE that the first level of the stimulus must be coded with -1 and the second level with 1**. 

The confusion matrix is simply a 4x4 matrix of response frequencies to these stimulus categories. Rows should correspond to stimuli and columns to responses; obviously the order should be the one defined by the former matrix.

## Specifying priors

Prior information is input as a data to the model. Each parameter is assigned  a normal prior. **IMPORTANT NOTE: The prior for the correlation coefficient is defined on the atanh-scale**: this simply transforms the real numher line to the interval -1 and 1. 

The user should supply the means and standard deviations for the mu-parameters of the latent distributions. Each mu will be assigned and independent normal prior. For the model with one correlation coefficient, the user should supply the mean and standard deviation of this prior, remembering that the normal prior is defined for the atanh transformed coefficient. See Examples for, well, examples of how this is done in practice. You won't regret. 

**IMPORTANT NOTE, PART 2: due to the aforementioned transformation on the correlation coefficient, and the fact that Stan randomly initializes the chains between -2 and 2, Stan will sometimes try to initialize the chain at an extreme correlation, which will lead to the chain getting stuck**. You will notice if this happens, since Stan will scream at you, R hats will be all over the place and so on. This could be rectified  in  many ways, for example by further transforming the value by dividing it by some constant, or maybe applying uniform prior on a scale that doesn't lead to problems, supllyin initial values by hand... Do what thou wilt. I don't think this is a serious problem as it is. 

## How are the models defined? 

There are quite a few ways one could go about defining a "standard" GRT model for a 2x2 recognition experiment. Here, I've opted to let the mus of the four latent bivariate normal distributions be free; decisional criteria are fixed at 0.0 on both axes. 

Correlation parameter, rho, can be fitted separately for each of the latent distributions or be shared among all of the distributions.

## Models included

- mdl2x2_one_rho
- mdl2x2_four_rhos

## R examples

Examplar data sets have been snatched from the R-library mdsdt. 
