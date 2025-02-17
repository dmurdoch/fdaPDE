CPP_smooth.FEM.basis<-function(locations, observations, FEMbasis, covariates = NULL, ndim, mydim, BC = NULL, incidence_matrix = NULL, areal.data.avg = TRUE, search, bary.locations, optim, lambda = NULL, DOF.stochastic.realizations = 100, DOF.stochastic.seed = 0, DOF.matrix = NULL, GCV.inflation.factor = 1, lambda.optimization.tolerance = 0.05, inference.data.object)
{
  # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
  
  FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
  FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
  FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1

  if(is.null(covariates))
  {
    covariates<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(DOF.matrix))
  {
    DOF.matrix<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(locations))
  {
    locations<-matrix(nrow = 0, ncol = 2)
  }

  if(is.null(incidence_matrix))
  {
    incidence_matrix<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(BC$BC_indices))
  {
    BC$BC_indices<-vector(length=0)
  }else
  {
    BC$BC_indices<-as.vector(BC$BC_indices)-1
  }

  if(is.null(BC$BC_values))
  {
    BC$BC_values<-vector(length=0)
  }else
  {
    BC$BC_values<-as.vector(BC$BC_values)
  }
  
  if(is.null(lambda))
  {
    lambda<-vector(length=0)
  }else
  {
    lambda<-as.vector(lambda)
  }

  ## Extract the parameters for inference from inference.data.object to prepare them for c++ reading
  test_Type<-as.vector(inference.data.object@test)
  interval_Type<-as.vector(inference.data.object@interval)
  implementation_Type<-as.vector(inference.data.object@type)
  component_Type<-as.vector(inference.data.object@component)
  exact_Inference<-inference.data.object@exact
  locs_Inference<-as.matrix(inference.data.object@locations)
  locs_index_Inference<-as.vector(inference.data.object@locations_indices - 1) #converting the indices from R to c++ ones 
  locs_are_nodes_Inference<-inference.data.object@locations_are_nodes
  coeff_Inference<-as.matrix(inference.data.object@coeff)
  beta_0<-as.vector(inference.data.object@beta0)
  f_0_eval<-as.vector(inference.data.object@f0_eval)
  f_var_Inference<-inference.data.object@f_var
  inference_Quantile<-as.vector(inference.data.object@quantile)
  inference_Alpha<-as.vector(inference.data.object@alpha)
  inference_N_Flip<-inference.data.object@n_flip
  inference_Tol_Fspai<-inference.data.object@tol_fspai
  inference_Defined<-inference.data.object@definition
  
  ## Set proper type for correct C++ reading
  locations <- as.matrix(locations)
  storage.mode(locations) <- "double"
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$mesh$triangles) <- "integer"
  storage.mode(FEMbasis$mesh$edges) <- "integer"
  storage.mode(FEMbasis$mesh$neighbors) <- "integer"
  storage.mode(FEMbasis$order) <- "integer"
  covariates <- as.matrix(covariates)
  storage.mode(covariates) <- "double"
  storage.mode(ndim) <- "integer"
  storage.mode(mydim) <- "integer"
  storage.mode(BC$BC_indices) <- "integer"
  storage.mode(BC$BC_values) <-"double"
  incidence_matrix <- as.matrix(incidence_matrix)
  storage.mode(incidence_matrix) <- "integer"
  areal.data.avg <- as.integer(areal.data.avg)
  storage.mode(areal.data.avg) <-"integer"
  storage.mode(search) <- "integer"
  storage.mode(optim) <- "integer"  
  storage.mode(lambda) <- "double"
  DOF.matrix <- as.matrix(DOF.matrix)
  storage.mode(DOF.matrix) <- "double"
  storage.mode(DOF.stochastic.realizations) <- "integer"
  storage.mode(DOF.stochastic.seed) <- "integer"
  storage.mode(GCV.inflation.factor) <- "double"
  storage.mode(lambda.optimization.tolerance) <- "double"
  
  ## Set proper type for correct C++ reading for inference parameters
  storage.mode(test_Type) <- "integer"
  storage.mode(interval_Type) <- "integer"
  storage.mode(implementation_Type) <- "integer"
  storage.mode(component_Type) <- "integer"
  storage.mode(exact_Inference) <- "integer"
  storage.mode(locs_Inference) <- "double"
  storage.mode(locs_index_Inference) <- "integer"
  storage.mode(locs_are_nodes_Inference) <- "integer"
  storage.mode(coeff_Inference) <- "double"
  storage.mode(beta_0) <- "double"
  storage.mode(f_0_eval) <- "double"
  storage.mode(f_var_Inference) <- "integer"
  storage.mode(inference_Quantile) <- "double"
  storage.mode(inference_Alpha) <- "double"
  storage.mode(inference_N_Flip) <- "integer"
  storage.mode(inference_Tol_Fspai) <- "double"
  storage.mode(inference_Defined) <- "integer"
  
  ## Call C++ function
  bigsol <- .Call("regression_Laplace", locations, bary.locations, observations, FEMbasis$mesh, FEMbasis$order,
                  mydim, ndim, covariates, BC$BC_indices, BC$BC_values, incidence_matrix, areal.data.avg, search,
                  optim, lambda, DOF.stochastic.realizations, DOF.stochastic.seed, DOF.matrix, 
                  GCV.inflation.factor, lambda.optimization.tolerance,
                  test_Type,interval_Type,implementation_Type,component_Type,exact_Inference,locs_Inference,locs_index_Inference,locs_are_nodes_Inference,coeff_Inference,beta_0,
                  f_0_eval,f_var_Inference,inference_Quantile,inference_Alpha,inference_N_Flip,inference_Tol_Fspai, inference_Defined,
                  PACKAGE = "fdaPDE")
  return(bigsol)
}

CPP_smooth.FEM.PDE.basis<-function(locations, observations, FEMbasis, covariates = NULL, PDE_parameters, ndim, mydim, BC = NULL, incidence_matrix = NULL, areal.data.avg = TRUE, search, bary.locations, optim, lambda = NULL, DOF.stochastic.realizations = 100, DOF.stochastic.seed = 0, DOF.matrix = NULL, GCV.inflation.factor = 1, lambda.optimization.tolerance = 0.05, inference.data.object)
{

  # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation

  FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
  FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
  FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
  #
  if(is.null(covariates))
  {
    covariates<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(DOF.matrix))
  {
    DOF.matrix<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(locations))
  {
    locations<-matrix(nrow = 0, ncol = 2)
  }

  if(is.null(incidence_matrix))
  {
    incidence_matrix<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(BC$BC_indices))
  {
    BC$BC_indices<-vector(length=0)
  }else
  {
    BC$BC_indices<-as.vector(BC$BC_indices)-1
  }

  if(is.null(BC$BC_values))
  {
    BC$BC_values<-vector(length=0)
  }else
  {
    BC$BC_values<-as.vector(BC$BC_values)
  }

  if(is.null(lambda))
  {
    lambda<-vector(length=0)
  }else
  {
    lambda<-as.vector(lambda)
  }
  
  ## Extract the parameters for inference from inference.data.object to prepare them for c++ reading
  test_Type<-as.vector(inference.data.object@test)
  interval_Type<-as.vector(inference.data.object@interval)
  implementation_Type<-as.vector(inference.data.object@type)
  component_Type<-as.vector(inference.data.object@component)
  exact_Inference<-inference.data.object@exact
  locs_Inference<-as.matrix(inference.data.object@locations)
  locs_index_Inference<-as.vector(inference.data.object@locations_indices - 1) #converting indices from R to c++ ones 
  locs_are_nodes_Inference <- inference.data.object@locations_are_nodes
  coeff_Inference<-as.matrix(inference.data.object@coeff)
  beta_0<-as.vector(inference.data.object@beta0)
  f_0_eval<-as.vector(inference.data.object@f0_eval)
  f_var_Inference<-inference.data.object@f_var
  inference_Quantile<-as.vector(inference.data.object@quantile)
  inference_Alpha<-as.vector(inference.data.object@alpha)
  inference_N_Flip<-inference.data.object@n_flip
  inference_Tol_Fspai<-inference.data.object@tol_fspai
  inference_Defined<-inference.data.object@definition

  ## Set propr type for correct C++ reading

  locations <- as.matrix(locations)
  storage.mode(locations) <- "double"
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$mesh$triangles) <- "integer"
  storage.mode(FEMbasis$mesh$edges) <- "integer"
  storage.mode(FEMbasis$mesh$neighbors) <- "integer"
  storage.mode(FEMbasis$order) <- "integer"
  covariates <- as.matrix(covariates)
  storage.mode(covariates) <- "double"
  storage.mode(PDE_parameters$K) <- "double"
  storage.mode(PDE_parameters$b) <- "double"
  storage.mode(PDE_parameters$c) <- "double"
  storage.mode(ndim) <- "integer"
  storage.mode(mydim) <- "integer"
  storage.mode(BC$BC_indices) <- "integer"
  storage.mode(BC$BC_values) <-"double"
  incidence_matrix <- as.matrix(incidence_matrix)
  storage.mode(incidence_matrix) <- "integer"
  areal.data.avg <- as.integer(areal.data.avg)
  storage.mode(areal.data.avg) <-"integer"
  storage.mode(search) <- "integer"
  storage.mode(optim) <- "integer"  
  storage.mode(lambda) <- "double"
  DOF.matrix <- as.matrix(DOF.matrix)
  storage.mode(DOF.matrix) <- "double"
  storage.mode(DOF.stochastic.realizations) <- "integer"
  storage.mode(DOF.stochastic.seed) <- "integer"
  storage.mode(GCV.inflation.factor) <- "double"
  storage.mode(lambda.optimization.tolerance) <- "double"
  
  ## Set proper type for correct C++ reading for inference parameters
  storage.mode(test_Type) <- "integer"
  storage.mode(interval_Type) <- "integer"
  storage.mode(implementation_Type) <- "integer"
  storage.mode(component_Type) <- "integer"
  storage.mode(exact_Inference) <- "integer"
  storage.mode(locs_Inference) <- "double"
  storage.mode(locs_index_Inference) <- "integer"
  storage.mode(locs_are_nodes_Inference) <- "integer"
  storage.mode(coeff_Inference) <- "double"
  storage.mode(beta_0) <- "double"
  storage.mode(f_0_eval) <- "double"
  storage.mode(f_var_Inference) <- "integer"
  storage.mode(inference_Quantile) <- "double"
  storage.mode(inference_Alpha) <- "double"
  storage.mode(inference_N_Flip) <- "integer"
  storage.mode(inference_Tol_Fspai) <- "double"
  storage.mode(inference_Defined) <- "integer"

  ## Call C++ function
  bigsol <- .Call("regression_PDE", locations, bary.locations, observations, FEMbasis$mesh, FEMbasis$order, 
                  mydim, ndim, PDE_parameters$K, PDE_parameters$b, PDE_parameters$c, covariates,
                  BC$BC_indices, BC$BC_values, incidence_matrix, areal.data.avg, search,
                  optim, lambda, DOF.stochastic.realizations, DOF.stochastic.seed, DOF.matrix,
                  GCV.inflation.factor, lambda.optimization.tolerance,
                  test_Type,interval_Type,implementation_Type,component_Type,exact_Inference,locs_Inference,locs_index_Inference,locs_are_nodes_Inference,coeff_Inference,beta_0,
                  f_0_eval,f_var_Inference,inference_Quantile,inference_Alpha,inference_N_Flip, inference_Tol_Fspai, inference_Defined,
                  PACKAGE = "fdaPDE")
  return(bigsol)
}

CPP_smooth.FEM.PDE.sv.basis<-function(locations, observations, FEMbasis, covariates = NULL, PDE_parameters, ndim, mydim, BC = NULL, incidence_matrix = NULL, areal.data.avg = TRUE, search, bary.locations, optim, lambda = NULL, DOF.stochastic.realizations = 100, DOF.stochastic.seed = 0, DOF.matrix = NULL, GCV.inflation.factor = 1, lambda.optimization.tolerance = 0.05, inference.data.object)
{

  # Indexes in C++ starts from 0, in R from 1, opportune transformation
  FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
  FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
  FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1

  if(is.null(covariates))
  {
    covariates<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(DOF.matrix))
  {
    DOF.matrix<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(locations))
  {
    locations<-matrix(nrow = 0, ncol = 2)
  }

  if(is.null(incidence_matrix))
  {
    incidence_matrix<-matrix(nrow = 0, ncol = 1)
  }

  if(is.null(BC$BC_indices))
  {
    BC$BC_indices<-vector(length=0)
  }else
  {
    BC$BC_indices<-as.vector(BC$BC_indices)-1
  }

  if(is.null(BC$BC_values))
  {
    BC$BC_values<-vector(length=0)
  }else
  {
    BC$BC_values<-as.vector(BC$BC_values)
  }
  
  if(is.null(lambda))
  {
    lambda<-vector(length=0)
  }else
  {
    lambda<-as.vector(lambda)
  }

  PDE_param_eval = NULL
  points_eval = matrix(CPP_get_evaluations_points(mesh = FEMbasis$mesh, order = FEMbasis$order),ncol = 2)
  PDE_param_eval$K = (PDE_parameters$K)(points_eval)
  PDE_param_eval$b = (PDE_parameters$b)(points_eval)
  PDE_param_eval$c = (PDE_parameters$c)(points_eval)
  PDE_param_eval$u = (PDE_parameters$u)(points_eval)
  
  if(inference.data.object@definition==1 && mean(PDE_param_eval$u != rep(0, nrow(points_eval)))!=0){
    warning("Inference is implemented only if reaction term is zero, \nInference Data are ignored")
    inference.data.object=new("inferenceDataObject", test = as.integer(0), interval = as.integer(0), type = as.integer(0), component = as.integer(0), exact = as.integer(0), dim = as.integer(0), n_cov = as.integer(0),
                                 locations = matrix(data=0, nrow = 1 ,ncol = 1), coeff = matrix(data=0, nrow = 1 ,ncol = 1), beta0 = -1, f0 = function(){}, f_var = as.integer(0), quantile = -1, n_flip = as.integer(1000), tol_fspai = -1, definition=as.integer(0))
  }
  
  ## Extract the parameters for inference from inference.data.object to prepare them for c++ reading
  test_Type<-as.vector(inference.data.object@test)
  interval_Type<-as.vector(inference.data.object@interval)
  implementation_Type<-as.vector(inference.data.object@type)
  component_Type<-as.vector(inference.data.object@component)
  exact_Inference<-inference.data.object@exact
  locs_Inference<-as.matrix(inference.data.object@locations)
  locs_index_Inference<-as.vector(inference.data.object@locations_indices - 1) #converting indices from R to c++ ones 
  locs_are_nodes_Inference <- inference.data.object@locations_are_nodes
  coeff_Inference<-as.matrix(inference.data.object@coeff)
  beta_0<-as.vector(inference.data.object@beta0)
  f_0_eval<-as.vector(inference.data.object@f0_eval)
  f_var_Inference<-inference.data.object@f_var
  inference_Quantile<-as.vector(inference.data.object@quantile)
  inference_Alpha<-as.vector(inference.data.object@alpha)
  inference_N_Flip<-inference.data.object@n_flip
  inference_Tol_Fspai<-inference.data.object@tol_fspai
  inference_Defined<-inference.data.object@definition
  
  ## Set proper type for correct C++ reading
  locations <- as.matrix(locations)
  storage.mode(locations) <- "double"
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$mesh$triangles) <- "integer"
  storage.mode(FEMbasis$mesh$edges) <- "integer"
  storage.mode(FEMbasis$mesh$neighbors) <- "integer"
  storage.mode(FEMbasis$order) <- "integer"
  covariates <- as.matrix(covariates)
  storage.mode(covariates) <- "double"
  storage.mode(PDE_param_eval$K) <- "double"
  storage.mode(PDE_param_eval$b) <- "double"
  storage.mode(PDE_param_eval$c) <- "double"
  storage.mode(PDE_param_eval$u) <- "double"
  storage.mode(ndim) <- "integer"
  storage.mode(mydim) <- "integer"
  storage.mode(BC$BC_indices) <- "integer"
  storage.mode(BC$BC_values) <-"double"
  incidence_matrix <- as.matrix(incidence_matrix)
  storage.mode(incidence_matrix) <- "integer"
  areal.data.avg <- as.integer(areal.data.avg)
  storage.mode(areal.data.avg) <-"integer"
  storage.mode(search) <- "integer"
  storage.mode(optim) <- "integer"  
  storage.mode(lambda) <- "double"
  DOF.matrix <- as.matrix(DOF.matrix)
  storage.mode(DOF.matrix) <- "double"
  storage.mode(DOF.stochastic.realizations) <- "integer"
  storage.mode(DOF.stochastic.seed) <- "integer"
  storage.mode(GCV.inflation.factor) <- "double"
  storage.mode(lambda.optimization.tolerance) <- "double"

  ## Set proper type for correct C++ reading for inference parameters
  storage.mode(test_Type) <- "integer"
  storage.mode(interval_Type) <- "integer"
  storage.mode(implementation_Type) <- "integer"
  storage.mode(component_Type) <- "integer"
  storage.mode(exact_Inference) <- "integer"
  storage.mode(locs_Inference) <- "double"
  storage.mode(locs_index_Inference) <- "integer"
  storage.mode(locs_are_nodes_Inference) <- "integer"
  storage.mode(coeff_Inference) <- "double"
  storage.mode(beta_0) <- "double"
  storage.mode(f_0_eval) <- "double"
  storage.mode(f_var_Inference) <- "integer"
  storage.mode(inference_Quantile) <- "double"
  storage.mode(inference_Alpha) <- "double"
  storage.mode(inference_N_Flip) <- "integer"
  storage.mode(inference_Tol_Fspai) <- "double"
  storage.mode(inference_Defined) <- "integer"
  
  ## Call C++ function
  bigsol <- .Call("regression_PDE_space_varying", locations, bary.locations, observations, FEMbasis$mesh, FEMbasis$order,
                  mydim, ndim, PDE_param_eval$K, PDE_param_eval$b, PDE_param_eval$c, PDE_param_eval$u, covariates,
                  BC$BC_indices, BC$BC_values, incidence_matrix, areal.data.avg, search,
                  optim, lambda, DOF.stochastic.realizations, DOF.stochastic.seed, DOF.matrix,
                  GCV.inflation.factor, lambda.optimization.tolerance,
                  test_Type,interval_Type,implementation_Type,component_Type,exact_Inference,locs_Inference,locs_index_Inference,locs_are_nodes_Inference,coeff_Inference,beta_0,
                  f_0_eval,f_var_Inference,inference_Quantile, inference_Alpha, inference_N_Flip, inference_Tol_Fspai, inference_Defined,
                  PACKAGE = "fdaPDE")
  return(bigsol)
}


CPP_eval.FEM = function(FEM, locations, incidence_matrix, redundancy, ndim, mydim, search, bary.locations)
{

  # EVAL_FEM_FD evaluates the FEM fd object at points (X,Y)
  #
  #        arguments:
  # X         an array of x-coordinates.
  # Y         an array of y-coordinates.
  # FELSPLOBJ a FELspline object
  # FAST      a boolean indicating if the walking algorithm should be apply
  #        output:
  # EVALMAT   an array of the same size as X and Y containing the value of
  #           FELSPLOBJ at (X,Y).

  FEMbasis = FEM$FEMbasis
  # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation

  FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
  FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
  FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1

  # Imposing types, this is necessary for correct reading from C++
  ## Set proper type for correct C++ reading
  locations <- as.matrix(locations)
  storage.mode(locations) <- "double"
  incidence_matrix <- as.matrix(incidence_matrix)
  storage.mode(incidence_matrix) <- "integer"
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$mesh$triangles) <- "integer"
  storage.mode(FEMbasis$mesh$edges) <- "integer"
  storage.mode(FEMbasis$mesh$neighbors) <- "integer"
  storage.mode(FEMbasis$order) <- "integer"
  coeff <- as.matrix(FEM$coeff)
  storage.mode(coeff) <- "double"
  storage.mode(ndim) <- "integer"
  storage.mode(mydim) <- "integer"
  storage.mode(locations) <- "double"
  storage.mode(redundancy) <- "integer"
  storage.mode(search) <- "integer"

  if(!is.null(bary.locations))
  {
    storage.mode(bary.locations$element_ids) <- "integer"
    element_ids <- as.matrix(bary.locations$element_ids)
    storage.mode(bary.locations$barycenters) <- "double"
    barycenters <- as.matrix(bary.locations$barycenters)
  }else{
    bary.locations = list(locations=matrix(nrow=0,ncol=ndim), element_ids=matrix(nrow=0,ncol=1), barycenters=matrix(nrow=0,ncol=2))
    storage.mode(bary.locations$locations) <- "double"
    storage.mode(bary.locations$element_ids) <- "integer"
    storage.mode(bary.locations$barycenters) <- "double"
  }

  #Calling the C++ function "eval_FEM_fd" in RPDE_interface.cpp
  evalmat = matrix(0,max(nrow(locations),nrow(incidence_matrix)),ncol(coeff))
  for (i in 1:ncol(coeff)){
    evalmat[,i] <- .Call("eval_FEM_fd", FEMbasis$mesh, locations, incidence_matrix, as.matrix(coeff[,i]),
                         FEMbasis$order, redundancy, mydim, ndim, search, bary.locations, PACKAGE = "fdaPDE")
  }

  #Returning the evaluation matrix
  evalmat
}


CPP_get_evaluations_points = function(mesh, order)
{
  #here we do not shift indices since this function is called inside CPP_smooth.FEM.PDE.sv.basis

  # Imposing types, this is necessary for correct reading from C++
  if(is(mesh, "mesh.2D")){
    ndim = 2
    mydim = 2
  }else if(is(mesh, "mesh.2.5D")){
    ndim = 3
    mydim = 2
  }else if(is(mesh, "mesh.3D")){
    ndim = 3
    mydim = 3
  }else{
    stop('Unknown mesh class')
  }

  storage.mode(ndim)<-"integer"
  storage.mode(mydim)<-"integer"
  storage.mode(mesh$nodes) <- "double"
  if(mydim==2){
    storage.mode(mesh$triangles) <- "integer"
    storage.mode(mesh$edges) <- "integer"
  }
  else if(mydim==3){
    storage.mode(mesh$tetrahedrons) <- "integer"
    storage.mode(mesh$faces) <- "integer"
  }

  storage.mode(mesh$neighbors) <- "integer"
  storage.mode(order) <- "integer"


  points <- .Call("get_integration_points",mesh, order,mydim, ndim,
                  PACKAGE = "fdaPDE")

  #Returning the evaluation matrix
  points
}

CPP_get.FEM.Mass.Matrix<-function(FEMbasis)
{
  if(is(FEMbasis$mesh, "mesh.2D")){
    ndim = 2
    mydim = 2
  }else if(is(FEMbasis$mesh, "mesh.1.5D")){
    ndim = 2
    mydim = 1
  }else if(is(FEMbasis$mesh, "mesh.2.5D")){
    ndim = 3
    mydim = 2
  }else if(is(FEMbasis$mesh, "mesh.3D")){
    ndim = 3
    mydim = 3
  }else{
    stop('Unknown mesh class')
  }

  ## Set propr type for correct C++ reading
   if( (ndim==2 && mydim==2) || (ndim==3 && mydim==2) ){
   # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation

   FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
   FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
   FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1

   ## Set propr type for correct C++ reading
   storage.mode(FEMbasis$mesh$triangles) <- "integer"
   storage.mode(FEMbasis$mesh$edges) <- "integer"
   storage.mode(FEMbasis$mesh$neighbors) <- "integer"
   
  }else if( ndim==2 && mydim==1){
   # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
   FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
    
   ## Set propr type for correct C++ reading
   storage.mode(FEMbasis$mesh$edges) <- "integer"
   
  }else if( ndim==3 && mydim==3){
   # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
   FEMbasis$mesh$tetrahedrons = FEMbasis$mesh$tetrahedrons - 1
   FEMbasis$mesh$faces = FEMbasis$mesh$faces - 1
   FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
   
   ## Set propr type for correct C++ reading
   storage.mode(FEMbasis$mesh$faces) <- "integer"
   storage.mode(FEMbasis$mesh$neighbors) <- "integer"
   storage.mode(FEMbasis$mesh$tetrahedrons) <- "integer"
  }
  
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$order) <- "integer"
  storage.mode(ndim)<-"integer"
  storage.mode(mydim)<-"integer"


  ## Call C++ function
  triplets <- .Call("get_FEM_mass_matrix", FEMbasis$mesh,
                    FEMbasis$order,mydim, ndim,
                    PACKAGE = "fdaPDE")

  A = sparseMatrix(i = triplets[[1]][,1], j=triplets[[1]][,2], x = triplets[[2]], dims = c(nrow(FEMbasis$mesh$nodes),nrow(FEMbasis$mesh$nodes)))
  return(A)
}

CPP_get.FEM.Stiff.Matrix<-function(FEMbasis)
{
  if(is(FEMbasis$mesh, "mesh.2D")){
    ndim = 2
    mydim = 2
  }else if(is(FEMbasis$mesh, "mesh.1.5D")){
    ndim = 2
    mydim = 1
  }else if(is(FEMbasis$mesh, "mesh.2.5D")){
    ndim = 3
    mydim = 2
  }else if(is(FEMbasis$mesh, "mesh.3D")){
    ndim = 3
    mydim = 3
  }else{
    stop('Unknown mesh class')
  }

  if( (ndim ==2 && mydim==2) || (ndim==3 && mydim==2) ){
   # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
   FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
   FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
   FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
  
   ## Set propr type for correct C++ reading
   storage.mode(FEMbasis$mesh$triangles) <- "integer"
   storage.mode(FEMbasis$mesh$edges) <- "integer"
   storage.mode(FEMbasis$mesh$neighbors) <- "integer"
  
  }else if(ndim==2 && mydim==1){
   # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
   FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
   
   ## Set propr type for correct C++ reading 
   storage.mode(FEMbasis$mesh$edges) <- "integer"
  
  }else if( ndim==3 && mydim==3){
   # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
   FEMbasis$mesh$tetrahedrons = FEMbasis$mesh$tetrahedrons - 1
   FEMbasis$mesh$faces = FEMbasis$mesh$faces - 1
   FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
   
   ## Set propr type for correct C++ reading
   storage.mode(FEMbasis$mesh$faces) <- "integer"
   storage.mode(FEMbasis$mesh$neighbors) <- "integer"
   storage.mode(FEMbasis$mesh$tetrahedrons) <- "integer"
  }
  
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$order) <- "integer"
  storage.mode(ndim)<-"integer"
  storage.mode(mydim)<-"integer"

  ## Call C++ function
  triplets <- .Call("get_FEM_stiff_matrix", FEMbasis$mesh,
                    FEMbasis$order, mydim, ndim,
                    PACKAGE = "fdaPDE")

  A = sparseMatrix(i = triplets[[1]][,1], j=triplets[[1]][,2], x = triplets[[2]], dims = c(nrow(FEMbasis$mesh$nodes),nrow(FEMbasis$mesh$nodes)))
  return(A)
}

CPP_get.FEM.PDE.Matrix<-function(observations, FEMbasis, PDE_parameters)
{
  search = 1
  if(is(FEMbasis$mesh, "mesh.2D")){
    ndim = 2
    mydim = 2
    
    # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
    FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
    FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
    FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
    
    ## Set propr type for correct C++ reading
    storage.mode(FEMbasis$mesh$triangles) <- "integer"
    storage.mode(FEMbasis$mesh$edges) <- "integer"
    storage.mode(FEMbasis$mesh$neighbors) <- "integer"
  
  }else if(is(FEMbasis$mesh, "mesh.3D")){
    ndim = 3
    mydim = 3
    
    # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
    FEMbasis$mesh$tetrahedrons = FEMbasis$mesh$tetrahedrons - 1
    FEMbasis$mesh$faces = FEMbasis$mesh$faces - 1
    FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
    
    ## Set propr type for correct C++ reading
    storage.mode(FEMbasis$mesh$tetrahedrons) <- "integer"
    storage.mode(FEMbasis$mesh$faces) <- "integer"
    storage.mode(FEMbasis$mesh$neighbors) <- "integer"
    
  }else if(is(FEMbasis$mesh, "mesh.2.5D") || is(mesh, "mesh.1.5D")){
    stop('Function not yet implemented for this mesh class')
  }else{
    stop('Unknown mesh class')
  }
  
  covariates <- matrix(nrow = 0, ncol = 1)
  locations <- matrix(nrow = 0, ncol = ndim)
  incidence_matrix <- matrix(nrow = 0, ncol = 1)
  areal.data.avg = 1
  BC_indices <- vector(length = 0)
  BC_values <- vector(length = 0)
  bary.locations = list(locations=matrix(nrow=0,ncol=ndim), element_ids=matrix(nrow=0,ncol=1), barycenters=matrix(nrow=0,ncol=2))
  
  ## Set proper type for correct C++ reading
  locations <- as.matrix(locations)
  storage.mode(locations) <- "double"
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$order) <- "integer"
  covariates <- as.matrix(covariates)
  storage.mode(covariates) <- "double"
  storage.mode(PDE_parameters$K) <- "double"
  storage.mode(PDE_parameters$b) <- "double"
  storage.mode(PDE_parameters$c) <- "double"
  storage.mode(BC_indices) <- "integer"
  storage.mode(BC_values) <- "double"
  storage.mode(ndim) <- "integer"
  storage.mode(mydim) <- "integer"
  incidence_matrix <- as.matrix(incidence_matrix)
  storage.mode(incidence_matrix) <- "integer"
  areal.data.avg <- as.integer(areal.data.avg)
  storage.mode(areal.data.avg) <-"integer"
  storage.mode(search) <- "integer"
  storage.mode(bary.locations$locations) <- "double"
  storage.mode(bary.locations$element_ids) <- "integer"
  storage.mode(bary.locations$barycenters) <- "double"

  
  ## Call C++ function
  triplets <- .Call("get_FEM_PDE_matrix", locations, bary.locations, observations, FEMbasis$mesh,
                    FEMbasis$order,mydim, ndim, PDE_parameters$K, PDE_parameters$b, PDE_parameters$c, covariates,
                    BC_indices, BC_values, incidence_matrix, areal.data.avg, search, PACKAGE = "fdaPDE")

  A = sparseMatrix(i = triplets[[1]][,1], j=triplets[[1]][,2], x = triplets[[2]], dims = c(nrow(FEMbasis$mesh$nodes),nrow(FEMbasis$mesh$nodes)))
  return(A)
}


CPP_get.FEM.PDE.sv.Matrix<-function(observations, FEMbasis, PDE_parameters)
{
  search = 1
  if(is(FEMbasis$mesh, "mesh.2D")){
    ndim = 2
    mydim = 2
    
    # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
    FEMbasis$mesh$triangles = FEMbasis$mesh$triangles - 1
    FEMbasis$mesh$edges = FEMbasis$mesh$edges - 1
    FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
    
    ## Set propr type for correct C++ reading
    storage.mode(FEMbasis$mesh$triangles) <- "integer"
    storage.mode(FEMbasis$mesh$edges) <- "integer"
    storage.mode(FEMbasis$mesh$neighbors) <- "integer"
  
  }else if(is(FEMbasis$mesh, "mesh.3D")){
    ndim = 3
    mydim = 3
    
    # Indexes in C++ starts from 0, in R from 1, opporGCV.inflation.factor transformation
    FEMbasis$mesh$tetrahedrons = FEMbasis$mesh$tetrahedrons - 1
    FEMbasis$mesh$faces = FEMbasis$mesh$faces - 1
    FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] = FEMbasis$mesh$neighbors[FEMbasis$mesh$neighbors != -1] - 1
    
    ## Set propr type for correct C++ reading
    storage.mode(FEMbasis$mesh$tetrahedrons) <- "integer"
    storage.mode(FEMbasis$mesh$faces) <- "integer"
    storage.mode(FEMbasis$mesh$neighbors) <- "integer"
    
  }else if(is(FEMbasis$mesh, "mesh.2.5D") || is(mesh, "mesh.1.5D")){
    stop('Function not yet implemented for this mesh class')
  }else{
    stop('Unknown mesh class')
  }

  covariates<-matrix(nrow = 0, ncol = 1)
  locations<-matrix(nrow = 0, ncol = ndim)
  BC_indices<-vector(length=0)
  BC_values<-vector(length=0)
  incidence_matrix<-matrix(nrow = 0, ncol = 1)
  areal.data.avg = 1
  bary.locations = list(locations=matrix(nrow=0,ncol=ndim), element_ids=matrix(nrow=0,ncol=1), barycenters=matrix(nrow=0,ncol=2))
  
  PDE_param_eval = NULL
  points_eval = matrix(CPP_get_evaluations_points(mesh = FEMbasis$mesh, order = FEMbasis$order),ncol = ndim)
  PDE_param_eval$K = (PDE_parameters$K)(points_eval)
  PDE_param_eval$b = (PDE_parameters$b)(points_eval)
  PDE_param_eval$c = (PDE_parameters$c)(points_eval)
  PDE_param_eval$u = (PDE_parameters$u)(points_eval)

  ## Set propr type for correct C++ reading
  locations <- as.matrix(locations)
  storage.mode(locations) <- "double"
  storage.mode(FEMbasis$mesh$nodes) <- "double"
  storage.mode(FEMbasis$order) <- "integer"
  covariates <- as.matrix(covariates)
  storage.mode(covariates) <- "double"

  storage.mode(PDE_param_eval$K) <- "double"
  storage.mode(PDE_param_eval$b) <- "double"
  storage.mode(PDE_param_eval$c) <- "double"
  storage.mode(PDE_param_eval$u) <- "double"

  storage.mode(BC_indices) <- "integer"
  storage.mode(BC_values) <- "double"
  storage.mode(ndim) <- "integer"
  storage.mode(mydim) <- "integer"
  incidence_matrix <- as.matrix(incidence_matrix)
  storage.mode(incidence_matrix) <- "integer"
  areal.data.avg <- as.integer(areal.data.avg)
  storage.mode(areal.data.avg) <-"integer"
  storage.mode(search) <- "integer"
  storage.mode(bary.locations$locations) <- "double"
  storage.mode(bary.locations$element_ids) <- "integer"
  storage.mode(bary.locations$barycenters) <- "double"

  
  ## Call C++ function
  triplets <- .Call("get_FEM_PDE_space_varying_matrix", locations, bary.locations, observations, FEMbasis$mesh,
                    FEMbasis$order,mydim, ndim, PDE_param_eval$K, PDE_param_eval$b, PDE_param_eval$c, PDE_param_eval$u, covariates,
                    BC_indices, BC_values, incidence_matrix, areal.data.avg, search, PACKAGE = "fdaPDE")

  A = sparseMatrix(i = triplets[[1]][,1], j=triplets[[1]][,2], x = triplets[[2]], dims = c(nrow(FEMbasis$mesh$nodes),nrow(FEMbasis$mesh$nodes)))
  return(A)
}
