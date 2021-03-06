## -----------------------------------------------------------------------------
## Calculates Water Viscosity
## -----------------------------------------------------------------------------

viscosity <- function (S = 35, t = 25, P = 1.013253) {

  if (any (S < 0))
    stop ("Salinity should be >= 0")
      1.7910 - t*(6.144e-02 - t*(1.4510e-03 - t*1.6826e-05))            +
      - 1.5290e-04*P + 8.3885e-08*P*P + 2.4727e-03*S                    +
      + (6.0574e-06*P - 2.6760e-09*P*P)*t + (t*(4.8429e-05              +
      - t*(4.7172e-06 - t*7.5986e-08)))*S
}
