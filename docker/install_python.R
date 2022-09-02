# ---- Description
# This file installs the required Python packages on the Docker image during the build time. 
# The list of packages and their versions is set on the packages.json file
# ---- Dependencies
# To parse the json jq must be installed on the docker image. 
# See: https://stedolan.github.io/jq/
# ---- Code starts here 
# Set the working directory
setwd("./packages")

# Set the Python packages
py_packages <- 'jq -r ".python_packages[] |  [.package, .version] | @tsv" packages.json'

raw <- system(command = py_packages, intern = TRUE)

x1 <- lapply(raw, function(i){
  x <- unlist(strsplit(x = i, split = "\t"))
  data.frame(package = x[1], version = x[2], stringsAsFactors = FALSE)
})

py_df <- NULL
tryCatch(
py_df <- as.data.frame(t(matrix(unlist(x1), nrow = 2)),
                         stringsAsFactors = FALSE),
  error = function(e){
    message("Function returned the following error:")
    print(e)
  },
  warning = function(w){
    message("Function returned the following warning:")
    print(w)
  }
)
conda_env <- system(command = "echo $CONDA_ENV", intern = TRUE)
python_ver <- system(command = "echo $PYTHON_VER", intern = TRUE)


# No need for the next two lines - already created on the base-r docker
#conda_create <- sprintf("conda create -y --name %s python=%s", conda_env, python_ver)
#system(command = conda_create)

if(!is.null(py_df) && nrow(py_df) > 0){
    names(py_df) <- c("package", "version")

    for(i in 1:nrow(py_df)){
       conda_install <- paste(". /root/.bashrc && ",
                              "conda activate ", conda_env," && ",
                              "conda info --envs && ",
                              "pip install ", 
                              py_df$package[i],
                              "==", 
                              py_df$version[i],
                              sep = "")
          system(command = conda_install)                     
    }
}


