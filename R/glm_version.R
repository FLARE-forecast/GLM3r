#'@title Return the current GLM model version 
#'
#'@description 
#'Returns the current version of the GLM model being used
#'
#'@keywords methods
#'
#'@author
#'Luke Winslow, Jordan Read
#'@examples 
#' print(glm_version())
#'
#'
#'@export
glm_version <- function(){
	.run_glm(dirname(nml_template_path()), verbose = TRUE, system.args='-help --no-gui')
}

.run_glm <- function(sim_folder = ".", nml_file = "glm3.nml", verbose = TRUE,
                    system.args = character()) {
  
  # Check for nml file in sim_folder
  if(!nml_file %in% list.files(sim_folder)){
    stop("You must have a valid .nml file in your sim_folder: ", sim_folder)
  }
  
  nml_arg <- paste0("--nml ", nml_file)
  system.args <- c(nml_arg, system.args)
  
  ### Windows ###
  if(.Platform$pkgType == "win.binary"){
    return(.run_glm3.0_Win(sim_folder, verbose, system.args))
  }
  
  ### macOS ###
  if (grepl("mac.binary",.Platform$pkgType)) { 
    maj_v_number <- as.numeric(strsplit(
      Sys.info()["release"][[1]],".", fixed = TRUE)[[1]][1])
    
    if (maj_v_number < 13.0) {
      stop("pre-mavericks mac OSX is not supported. Consider upgrading")
    }
    
    return(.run_glm3.0_OSx(sim_folder, verbose, system.args))
    
  }
  
  if(.Platform$pkgType == "source") {
    ## Probably running linux
    #stop("Currently UNIX is not supported by ", getPackageName())
    return(.run_glmNIX(sim_folder, verbose, system.args))
  }
  
}


.glm.systemcall <- function(sim_folder, glm_path, verbose, system.args) {
  
  if(nchar(Sys.getenv("GLM_PATH")) > 0){
    glm_path <- Sys.getenv("GLM_PATH")
    warning(paste0(
      "Custom path to GLM executable set via 'GLM_PATH' environment variable as: ", 
      glm_path))
  }
  
  origin <- getwd()
  setwd(sim_folder)
  
  ### macOS ###
  if (grepl("mac.binary",.Platform$pkgType)) { 
    dylib_path <- system.file("exec", package = packageName())
    tryCatch({
      if (verbose){
        out <- system2(glm_path, wait = TRUE, stdout = TRUE, 
                       stderr = "", args = system.args, env = paste0("DYLD_LIBRARY_PATH=", dylib_path))
      } else {
        out <- system2(glm_path, wait = TRUE, stdout = NULL, 
                       stderr = NULL, args = system.args, env = paste0("DYLD_LIBRARY_PATH=", dylib_path))
      }
    })
  } else {
    tryCatch({
      if (verbose){
        out <- system2(glm_path, wait = TRUE, stdout = TRUE, 
                       stderr = "", args = system.args)
      } else {
        out <- system2(glm_path, wait = TRUE, stdout = NULL, 
                       stderr = NULL, args = system.args)
      }
      setwd(origin)
      return(out)
    }, error = function(err) {
      print(paste("GLM_ERROR:  ",err))
      setwd(origin)
    })
  }
}

### Windows ###
.run_glm3.0_Win <- function(sim_folder, verbose, system.args){
  glm_path <- system.file("extbin/glm-3.0.5_x64/glm.exe", package = packageName())
  .glm.systemcall(sim_folder, glm_path, verbose, system.args)
}

### macOS ###
.run_glm3.0_OSx <- function(sim_folder, verbose, system.args){
  glm_path <- system.file("exec/macglm3", package = packageName())
  Sys.setenv(DYLD_LIBRARY_PATH = paste(system.file("exec", 
                                                   package = packageName()), 
                                       Sys.getenv("DYLD_LIBRARY_PATH"), 
                                       sep = ":"))
  .glm.systemcall(sim_folder = sim_folder, glm_path = glm_path, verbose = verbose, system.args = system.args)
}

### Linux ###
.run_glmNIX <- function(sim_folder, verbose, system.args){
  glm_path <- system.file("exec/nixglm", package = packageName())
  
  Sys.setenv(DYLD_LIBRARY_PATH = paste(system.file("extbin/nixGLM", 
                                                   package = packageName()), 
                                       Sys.getenv("DYLD_LIBRARY_PATH"), 
                                       sep = ":"))
  .glm.systemcall(sim_folder, glm_path, verbose, system.args)
  
}
