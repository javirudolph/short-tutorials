# DEMO script
# General Ecology course - PCB4043C
# Author: Javiera Rudolph
# Last edit: Septemeber 18, 2019


# Using R as a calculator:
## Simple calculations
4+3
5-2
5*10
98/3

## Some built in functions
mean(c(1,2,3,4,5,6))
round(pi, digits = 5)

## Generate random numbers with built in functions
rnorm(100)


## naming objects
# scalar object
a <- 2
# vector object
b <- c(5,6,3,4)
# matrix
c <- matrix(c(9,3,4,5,7,4), nrow = 3, ncol = 2)
# dataframe
d <- data.frame(x = c(0,1,2,3,4,5), y = c(0, 1, 4, 9, 16, 25))
# List
mylist <- list(a,b,c,d)

# Now you can explore how these object look in the Environment pane or by typing them in the console. 
a
b
c
#Access different columns/rows in the data frame
d
d$x
d$y
d[,1]
d[1,]

# Explore the structure of our list
mylist
mylist[[2]]


# vector with the random numbers generated
x <- rnorm(100)
#histogram of these random numbers
hist(x)

##plots
plot(d$x, d$y)

### modifying plots
plot(d$x, d$y, ylab = "Y axis name", xlab = "X axis label",
     main = "This is the main title for the plot",
     col = "red")

# Installing a package
install.packages('tidyverse')

# Using installed packages
library(tidyverse)

# A different kind of plot
ggplot(d, aes(x = x, y = y)) +
  geom_point(color = "red") +
  xlab("The x axis label") +
  ylab("The y axis label") +
  ggtitle("Your Plot's title", subtitle = "Any subtitle?")


# A bar plot
# We will add a column to the dataframe 
d$z <- c("red", "red", "red", "blue", "blue", "green")

ggplot(data = d, aes(x = z)) +
  geom_bar() +
  xlab("The x axis label") +
  ylab("The y axis label") +
  ggtitle("Your Plot's title", subtitle = "Any subtitle?")








