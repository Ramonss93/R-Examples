context("cluster_FarthestFirst")

test_that("cluster_FarthestFirst", {
  requirePackages("RWeka", default.method = "load")
  parset.list = list(
    list(N=3)
  )

  old.predicts.list = list()

  for (i in 1:length(parset.list)) {
    parset = parset.list[[i]]
    ctrl = do.call(RWeka::Weka_control, parset)
    set.seed(getOption("mlr.debug.seed"))
    m = RWeka::FarthestFirst(noclass.train, control = ctrl)
    p = predict(m, noclass.test) + 1
    old.predicts.list[[i]] = p
  }

  testSimpleParsets("cluster.FarthestFirst", noclass.df, character(0L), noclass.train.inds,
    old.predicts.list, parset.list)
})
