# You can use this script as a guide for line by line code
# DON'T run this whole script and don't use 'source()'
# This is meant to be a guide only

# Install packages if you don't have them
install.packages(c("devtools", "roxygen2", "usethis"))


# load the libraries
library(devtools)
library(roxygen2)
library(usethis)

# We are creating a minimal package
# It will be created in the current working directory
getwd()
# You can leave it or set it to a desired working directory
setwd("write your path here")

# Now, create your package
# You don't need to set up a project or anything, 'usethis' takes care of the setup
# After running the following line of code, you will have a new RStudio window open
usethis::create_package("rladiesgnv")


###########################################################################
# Customize Package -------------------------------------------------------
#   After your package is created, it will open in a new RStudio Session
#   The following lines of code should be run within the new package
#   You can run these in the console of the new RStudio session

usethis::use_r("rladies_color_function")

# You will see that a new R script opens.
# It has the name you set "rladies_color_function.R" 
# And it has automatically been save in the R/ directory

# We will write a simple function in the new script that was opened.
# You can copy the next set of lines and paste it in your new script within your package directory

gimme_color_codes <- function(wantAll = TRUE){
  hex_palette <- c("#181818", "#D3D3D3", "#88398A", "#FFFFF", "#562457")
  if(wantAll == TRUE){
    print(hex_palette)
  }
  else{
    print("You should go for all of them.")
  }
  
}

# And you are done with our minimal package! 
# You can now press 'crt + shift + l' or devtools::load_all() to load your package
# And test your function by writing it in the console!



# Adding some extra info --------------------------------------------------

# Documentation is probably one of the most important things when writting scripts
# Go back to your function script. You can actually type
usethis::use_r("gimme_color_function")
# in the console and it will open the function's script.
# Now, you can add the following lines for documentation

#' @title RLadies palette function
#'
#' @description This function will print out the hex codes for the RLadies palette
#' @param wantALL Do you want all the colors available in this palette? The default is TRUE
#' @keywords RLadies colors
#' @export
#' @examples
#' gimme_color_codes()
#'

# And after that, we can just press 'crtl + shift + d' or devtools::document()
# This will create the .Rd file in the /man directory
# It will also add the function to the NAMESPACE
# more info: http://r-pkgs.had.co.nz/man.html

# To check out your new documentation, let's install the package
# 'ctrl + shift + b' or devtools::install()
# search for your function with '?gimme_color_codes()

# Now you have a documented and functional minimal package


# Further -----------------------------------------------------------------

# Editing the description:
# details here: http://r-pkgs.had.co.nz/description.html

# Including a license
usethis::use_mit_license("Your name here")
# Include a README
usethis::use_readme_rmd()
# It will create a .Rmd file for you to render and edit as your normally would

# We went through the function documentation
# Now, let's edit the package documentation
usethis::use_package_doc()
# again, use document() to write the package documentation
devtools::document()



# Version Control ---------------------------------------------------------

# You can add a Git repo
usethis::use_git()
usethis::use_github()





