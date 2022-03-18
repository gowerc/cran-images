# CRAN Fedora UBSAN

This repo contains a dockerfile used to re-create CRAN's clang UBSAN test environment in order
to re-create an obsecure error message when using rstan.

To build the image run:
```
docker build -t cran-ubsan .
```

To re-create the error message in question first enter the container via:
```
docker run -it --rm cran-ubsan R
```

and then run:

```
library(rstan)

stancode <- "
data { real y[100]; }
parameters { real mu; real<lower=0> sigma; }
model { y ~ normal(mu,sigma);  }
"

model <- stan_model(model_code = stancode)

fit <- sampling(
    model,
    list(y = rnorm(100, 1.6, 0.2)),
    iter = 200,
    chains = 2,
    refresh = 0,
    seed = NA
)
```

