context("run example simulation")

test_that("running glm simulation", {
  sim_folder <- system.file('extdata', package = 'GLM3r')
  status = run_glm(sim_folder)
  
  expect_equivalent(status, 0)
  
  expect_true(file.exists(file.path(sim_folder, 'output/output.nc')))
  
})

test_that("running glm simulation - verbose = FALSE", {
  sim_folder <- system.file('extdata', package = 'GLM3r')
  status = run_glm(sim_folder, verbose = FALSE)
  
  expect_equivalent(status, 0)
  
  expect_true(file.exists(file.path(sim_folder, 'output/output.nc')))
  
})