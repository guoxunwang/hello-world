##Stats 506, F18, Problem Set 4, Question 2, Part b
##
##using doParrallel package to calculate four quantities
##
##Author: Xun Wang, xunwang@umich.edu
##Updated: December 8,2018- Lasted modified date

#80:--------------------------------------------------------------------------

#Libraries:-------------------------------------------------------------------
library(doParallel)

#Source code:-----------------------------------------------------------------
source("ps4_q2_funcs.R")

##set up a cluster called 'cl'
ncores=4
cl=makeCluster(ncores)

##register the cluster
registerDoParallel(cl)

##Part b
n=1000; p=100
beta=c(rep(.1,10), rep(0,p-10)) 
dim(beta)=c(p, 1)

##generate X for this function
X_0=matrix(rnorm(n*p),n,p)
sigma_beta=function(i){
  M=beta%*%t(beta)*i*.25
  diag(M)=c(rep(1,p))
  X_0%*%chol(M)}
X=foreach(i=-3:3)%dopar%{
  sigma_beta(i)
}

##compute p-values matrices and quantities with different comparison methods
multi_comparison_dopar=function(i,sigma){
  pvalue=sim_beta(X[[i]],beta=beta,sigma=sigma,mc_rep=1e4)
  m_adjust=mclapply(c('holm', 'bonferroni', 'BH', 'BY'),function(x){
    cbind(rho=0.25*(i-4),sigma=sigma,method=x,
          evaluate(apply(pvalue,2,p.adjust,method=x),tp_ind = 1:10))})
  do.call(rbind,m_adjust)
}

##sigma=.25
result_25=foreach(i=1:7,.combine='rbind', .packages='parallel')%dopar%{
  multi_comparison_dopar(i,sigma=.25)
}
##sigma=.5
result_5=foreach(i=1:7,.combine='rbind', .packages='parallel')%dopar%{
  multi_comparison_dopar(i,sigma=.5)
}
##sigma=1
result_1=foreach(i=1:7,.combine='rbind', .packages='parallel')%dopar%{
  multi_comparison_dopar(i,sigma=1)
}

##resultb
results_q4b=rbind(result_25,result_5,result_1)
save(results_q4b,file='results_q4b.RData')

##shut the cluster down when done
stopCluster(cl)

#80:--------------------------------------------------------------------------
