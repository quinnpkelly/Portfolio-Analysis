---
title: "Econ 424 Autumn 2024, HW 4 - ANSWERS"
author: "Due on Nov 6, 2024 via Canvas"
output:
  word_document: default
  html_notebook: default
  pdf_document: default
---

# Introduction

Please complete this HW by yourself; this will help sink in the ideas and steps behind the Mean-Variance Portfolio Analysis. Feel free to consult your group.\
In this HW you will:

-   Compute portfolios consisting of 1) Amazon and Starbucks, 2) T-bills and Amazon, 3) T-bills and Starbucks, and 4) T-bills and combinations of Amazon and Starbucks.
-   Use R functions to compute the global minimum variance portfolio and the tangency portfolio
-   Do simple asset allocation with efficient portfolios
-   This HW prepares you for HW5, which you will do portfolio analyses using all 5 assets

This notebook walks you through all of the computations for the HW. You will use the following R packages

-   **IntroCompFinR**
-   **PerformanceAnalytics**.
-   **zoo**
-   **xts**

Make sure to install these packages before you load them into R. As in the previous HW, use this notebook to answer all questions. Insert R chunks where needed. I will provide code hints below.

## Reading

-   EZ chapter 11 (Introduction to Portfolio Theory)
-   Ruppert and Matteson, Chapter 16 (Portfolio Selection)

## Load packages and set options

```{r}
library(IntroCompFinR)
library(PerformanceAnalytics)
library(xts)
options(digits = 3)
Sys.setenv(TZ="UTC")
```

## Data

For this HW you will use annualized estimates of the GWN model for Amazon and Starbucks, based on monthly simple returns over the period January 2018 through December 2023. First construct monthly returns from daily prices:

```{r}
setwd("/Users/quinnkelly/Downloads")
# Import 5 stock prices
fs.df = read.csv(file="Fivestocks.csv", header=TRUE, stringsAsFactors=FALSE)
rownames(fs.df) = fs.df$Date
fs.df = fs.df[, 2:6, drop=FALSE] 
fs.df = na.omit(fs.df)
FiveStocks = xts(fs.df, as.Date(rownames(fs.df), format="%m/%d/%y"))
FiveStocksMonthly = to.monthly(FiveStocks, OHLC=FALSE)
FiveStocksMonthlyRetS = na.omit(Return.calculate(FiveStocksMonthly, method="simple"))

amznSBUXRetS = merge(FiveStocksMonthlyRetS[,"AMZN"], FiveStocksMonthlyRetS[, "SBUX"])
smpl = "2018::2023"

amznSBUXRetS = amznSBUXRetS[smpl]
head(amznSBUXRetS, n=3)
```

Next, estimate the GWN model parameters for Amazon and Starbucks and annualize using the square root of time rule:

```{r}
muhat = apply(amznSBUXRetS, 2, mean)*12
sig2hat = apply(amznSBUXRetS, 2, var)*12
sighat = apply(amznSBUXRetS, 2, sd)*sqrt(12)
covhat = cov(amznSBUXRetS)[1,2]*12
rhohat = cor(amznSBUXRetS)[1,2]
```

The annualized expected returns are:

```{r}
muhat
```

The annualized variances are

```{r}
sig2hat
```

The annualized volatilities are

```{r}
sighat
```

The annualized covariance is

```{r}
covhat
```

The correlation, which is invariant to annualization, is

```{r}
rhohat
```

Assume a risk-free T-bill rate of $4\%$ per year.

```{r}
rf = 0.04
```

# Exercises

1.  Create the following portfolios:

    -   Combinations of Amazon and Starbucks with $x_{A}=-1, -0.9, \cdots, 2$ and $x_{B} = 1-x_{A}$.
    -   Combinations of Amazon and T-Bills with $x_{A}=0, 0.1 \cdots, 2$ and $x_{f} = 1-x_{A}$.
    -   Combinations of Starbucks and T-Bills with $x_{B}=0, 0.1 \cdots, 2$ and $x_{f} = 1-x_{B}$.

    For each set of portfolios compute $E[R_p]$, $var(R_p)$, $SD(R_p)$ using the appropriate formulas. For each set of portfolios plot $E[R_p]$ vs $SD(R_p)$ and put these all on the same risk-return graph. Compute Sharpe's slope for Amazon and Starbucks. Which asset has the highest slope value? Are you surprised?

First, create portfolios of Amazon and Starbucks

```{r}
muHat.A <- as.numeric(muhat["AMZN"])
muHat.B <- as.numeric(muhat["SBUX"])
sighat.A <- as.numeric(sighat["AMZN"])
sighat.B <- as.numeric(sighat["SBUX"])
sig2hat.A <- as.numeric(sig2hat["AMZN"])
sig2hat.B <- as.numeric(sig2hat["SBUX"])

sig.AB <- rhohat*sighat.A*sighat.B
x.A <- seq(-1, 2, by=0.1)
x.B <- 1-x.A
mu.p <- x.A*muHat.A + x.B*muHat.B
sig2.p <- x.A^2 * sig2hat.A + x.B^2 * sig2hat.B + 2*x.A*x.B*rhohat*sighat.A*sighat.B
sig.p <- sqrt(sig2.p)

cbind(mu.p, sig2.p, sig.p)
```

Next, create portfolios of T-Bills and AMZN

```{r}
x.Anew <- seq(0, 2, by = 0.1)
x.F <- 1 - x.Anew
mu.TA <- rf + x.Anew*(muHat.A - rf)
sd.TA <- x.Anew*sighat.A
var.TA <- sd.TA^2
sharpe.A <- (muHat.A - rf)/sighat.A
cbind(mu.TA, var.TA, sd.TA)
print(sharpe.A)
```

Finally, create portfolios of T-Bills and SBUX

```{r}
x.Bnew <- seq(0, 2, by = 0.1)
mu.TB <- rf + x.Bnew*(muHat.B - rf)
sd.TB <- x.Bnew*sighat.B
var.TB <- sd.TB^2
sharpe.B <- (muHat.B-rf)/sighat.B
cbind(mu.TB, sd.TB, var.TB)
print(sharpe.B)
```

Plot the portfolios

```{r}
plot(sig.p, mu.p, ylim = c(0, 0.3), xlim = c(0, 0.6), type = 'p', col = 'blue', pch = 19, main = "Risk-Return tradeoffs for portfolios")

lines(sd.TA, mu.TA, type = 'p', col = 'red', pch = 16)

lines(sd.TB, mu.TB, type = 'p', col = 'purple', pch = 16)


legend("topleft", 
       legend = c("AMZN/SBUX", "AMZN/T-bills", "SBUX/T-bills"),  
       col = c("blue", "red", "purple"),      
       pch = c(19, 16, 16),                  
       title = "Risk-Return")
```

2.  Compute the global minimum variance portfolio using the analytical formula presented in class and check with the **IntroCompFinR** function `globalMin.portfolio()`.
    -   Make a bar chart showing the weight of Amazon and Starbucks in global minimum variance portfolio.
    -   Compute $E[R_m]$, $var(R_m)$, and $SD(R_m)$
    -   Compute Sharpe's slope for the global minimum variance portfolio
    -   Indicate the location of the global minimum variance portfolio on the graph you created previously in question 1.

-   see bottom of page for updated graph \*

```{r}
x.Amin <- (sig2hat.B-covhat)/(sig2hat.A + sig2hat.B - 2*covhat)
x.Bmin <- 1 - x.Amin
c(x.Amin, x.Bmin)

sigma.mat <- matrix(c(sig2hat.A, covhat, covhat, sig2hat.B), nrow = 2, ncol = 2)
globalMin.portfolio(muhat, sigma.mat)

ew <- rep(1, 2)/2
equalWeight.portfolio <- getPortfolio(er = muhat, cov.mat = sigma.mat, weights = ew)

barplot(c(x.Amin, x.Bmin), col = c('blue', 'red'), names.arg = c("AMZN", "SBUX"), main = "Ideal weights of Amazon and Starbucks", xlab = "Firm", ylab = "weight")


# E[R_m], Var[R_m], SD[R_m]
muRM <- x.Amin * muHat.A + x.Bmin * muHat.B
varRM <- x.Amin^2 * sig2hat.A + x.Bmin^2 * sig2hat.B + 2*x.Amin*x.Bmin*rhohat*sighat.A*sighat.B
sdRM <- sqrt(varRM)
cbind(muRM, varRM, sdRM)

# sharpe's slope for the global minimum variance portfolio
sharpe.q2 <- (muRM - rf)/(sdRM)
print(sharpe.q2)
# my answers match what globalMin.portfolio told me the same thing that my manual computations did
```

3.  Using a risk-free rate of $4\%$ per year for the T-bill, compute the tangency portfolio using the analytical formula presented in class and check using the **IntroCompFinR** function `tangency.portfolio()`.

    -   If applicable, make a pie chart showing the weight of Amazon and Starbucks in the tangency portfolio; otherwise, report the numbers.
    -   Compute $E[R_t]$, $var(R_t)$, and $SD(R_t)$
    -   Compute Sharpe's slope for the tangency portfolio.
    -   Indicate the location of the tangency portfolio on the graph you created previously in question 1.

-   see bottom of page for updated graph \*

    ```{r}
    # analytical
    x.Atan <- ((muHat.A - rf)*sig2hat.B - (muHat.B - rf)*covhat)/((muHat.A - rf)*sig2hat.B + (muHat.B - rf)*sig2hat.A - (muHat.A - rf + muHat.B - rf)*covhat)
    x.Btan <- 1 - x.Atan
    cbind(x.Atan, x.Btan)

    tangency.portfolio(er = muhat, cov.mat = sigma.mat, risk.free = rf)

    # E[R_t], Var[R_t], SD[R_t]
    muT <- x.Atan * muHat.A + x.Btan * muHat.B
    varT <- x.Atan^2 * sig2hat.A + x.Btan^2 * sig2hat.B + 2*x.Atan*x.Btan*rhohat*sighat.A*sighat.B
    sdT <- sqrt(varT)
    cbind(muT, varT, sdT)

    slope <- (muT - rf)/sdT
    print(slope)

    pie(c(x.Atan * 100, x.Btan *100), labels = c("Amazon (58.7%)", "Starbucks (41.3%)"), main = "Portfolio allocations in the Tangency")
    ```

4.  Consider a portfolio that has $30\%$ in the tangency portfolio and $70\%$ in T-bills.

    -   In this portfolio, what is the percent invested in Amazon and what is the percent invested in Starbucks? Give a pie chart showing the percent invested in T-bills, Amazon and Starbucks.
    -   Compute $E[R_p]$, $var(R_p)$, $SD(R_p)$
    -   Compute Sharpe's slope for this portfolio
    -   Indicate the location of this portfolio on the graph you created previously in question 1.

-   see bottom of page for updated graph \*

```{r}
x.Amzn <- 0.3*x.Atan
x.Sbux <- 0.3*x.Btan
x.Tbill <- 0.7
cbind(x.Amzn, x.Sbux, x.Tbill)

muRp <- 0.3*muT + 0.7*rf
varRP <- 0.3^2 * varT
sdRP <- sqrt(varRP)
cbind(muRp, varRP, sdRP)

sharpeSlope <- (muRp - rf)/sdRP
print(sharpeSlope)

percentages <- c(x.Amzn * 100, x.Sbux * 100, x.Tbill * 100)
pie(percentages, labels = paste(c("Amazon", "Starbucks", "T-bills"), round(percentages, 1), "%"), main = "Ideal split of investments in the Portfolio", col = c('blue', 'green', 'orange'))
```

5.  Find the efficient portfolio (combination of T-bills and tangency portfolio) that has the same risk (SD) as Starbucks.

    -   In this portfolio, what is the percent invested in Amazon and what is the percent invested in Starbucks? Give a pie or bar chart showing the percent invested in T-bills, Amazon and Starbucks. (Note that pie charts are appropriate only when weights aren't negative.)
    -   Compute $E[R_p]$, $var(R_p)$, $SD(R_p)$
    -   Compute Sharpe's slope for this portfolio
    -   Indicate the location of this portfolio on the graph you created previously in question 1.

-   see bottom of page for the updated graph \*

```{r}
weight_t <- sighat.B/sdT

amzn.w.p <- weight_t * x.Atan
sbux.w.p <- weight_t * x.Btan
tbills.p <- 1 - weight_t
cbind(amzn.w.p, sbux.w.p, tbills.p)

barplot(c(amzn.w.p, sbux.w.p, tbills.p), ylim = c(-0.15, 0.8), names = c("Amazon (60.9%)", "Starbucks (42.8%)", "T-bills (-3.66%)"), col = c("blue", "green", "red"), main = "optimal portfolio allocation")

mu.P <- tbills.p * rf + amzn.w.p * muHat.A + sbux.w.p * muHat.B
var.P <- (amzn.w.p^2 * sig2hat.A + sbux.w.p^2 * sig2hat.B + 2 * amzn.w.p * sbux.w.p * covhat)
sd.P <- sqrt(var.P)

cbind(mu.P, var.P, sd.P)

sharpe.p <- (mu.P - rf)/sd.P
print(sharpe.p)
```

6.  Your uncle is very interested in these two local stocks and wants to know if he can use combinations of these assets to get an expected 25% annual return. How would you help him? What cautions may you want offer him? (hint: there may be different scenarios to consider.)

In order to achieve an expected 25% return, he would need to leverage more from T-bills, putting it further in the negatives, and invest more into amazon and starbucks. This, however, will increase risk, so it is not advised to do so. This will intensify the effects of the investment, both gains and losses.

Updated graph with all of the information from questions 1 - 6:

```{r}
plot(sig.p, mu.p, ylim = c(0, 0.4), xlim = c(0, 0.6), type = 'p', col = 'blue', pch = 19, main = "Risk-Return tradeoffs for portfolios")

lines(sd.TA, mu.TA, type = 'p', col = 'red', pch = 16)

lines(sd.TB, mu.TB, type = 'p', col = 'purple', pch = 16)

points(sdRM, muRM, pch = 16, col = 'green')
abline(a = rf, b = slope, lwd = 2)
points(sdRP, muRp, col = 'orange', pch = 16)
points(sd.P, mu.P, col = "cornflowerblue", pch = 16)


legend("topleft", 
       legend = c("AMZN/SBUX", "AMZN/T-bills", "SBUX/T-bills", "global min variance", "tangency", "70/30 portfolio (q4)", "portfolio from q5"),  
       col = c("blue", "red", "purple", "green", "black", 'orange', "cornflowerblue"),      
       pch = c(19, 16, 16, 16, 16, 16, 16), cex = 0.8)
```
