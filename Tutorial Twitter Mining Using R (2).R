# MINING TWITTER USER'S TIMELINE USING R (2): USING LOOPS
### WRITTEN BY JUNGHWAN YANG (jyang66@wisc.edu) ON SEPTEMBER 24, 2013
### MORE INFORMATION: http://goo.gl/J6pDUz

#--- 1. Install packages, set working directory, and load your Twitter credential

install.packages(c("twitteR", "ROAuth", "RCurl"))
library(twitteR);library(ROAuth);library(RCurl)

# Set up a working directory
setwd('/Users/YourWorkingDirectory')

load("twitteR_credentials")
registerTwitterOAuth(twitCred)

# In case you have so many Twitter users that you want to collect data of, you'd better build a loop.

#--- 1. Make sure you have a text file with Twitter usernames line by line (e.g., 'names.txt'). Place it inside your working directory.

#--- 2. Modify twListToDF function for our purpose

# Since twListToDF function (in twitteR package) requires to type 'enter' key, I removed 'browser()' function that bulit in twListToDF

### Modification starts here ###
getAPIStr <- function(cmd, version=1.1) {
  if (hasOAuth()) {
    scheme <- "https"
  } else {
    scheme <- "http"
  }
  paste(scheme, '://api.twitter.com/', version, '/', cmd, '.json', sep='')
}

buildCommonArgs <- function(lang=NULL, since=NULL, until=NULL, locale=NULL,
                            geocode=NULL, since_id=NULL, max_id=NULL,
                            lat=NULL, long=NULL, place_id=NULL,
                            display_coordinates=NULL,
                            in_reply_to_status_id=NULL, exclude=NULL,
                            date=NULL) {
  out <- list()
  for (arg in names(formals())) {
    val <- get(arg)
    if (length(val) > 0)
      out[[arg]] <- as.character(val)
  }
  out
}

parseUsers <- function(users) {
  ## many functions have 'user' input which can be one of class 'user', a UID or a screen name,
  ## try to do something rational here
  users <- sapply(users, function(x) {
    if (inherits(x, 'user'))
      x$getScreenName()
    else
      x
  })
  numUsers <- suppressWarnings(as.numeric(users))
  uids <- numUsers[!is.na(numUsers)]
  screen.names <- setdiff(users, uids)
  
  return(buildUserList(uids, screen.names))
}

buildUserList = function(uids, screen_names) {
  user_list = list()  
  if (length(uids) > 0) {
    user_list$user_id = paste(uids, collapse=',')
  }
  if (length(screen_names) > 0) {
    user_list$screen_name = paste(screen_names, collapse=',')
  }
  
  return(user_list)  
}

twListToDF <- function(twList) {
  ## iff all elements of twList are from a class defined in this
  ## package, and all of the same class, will collapse these into
  ## a data.frame and return
  classes <- unique(sapply(twList, class))
  if (length(classes) != 1) {
    stop("Not all elements of twList are of the same class")
  }
  if (! classes %in% c('status', 'user', 'directMessage', 'rateLimitInfo')) {
    stop("Elements of twList are not of an appropriate class")
  }
  do.call('rbind', lapply(twList, as.data.frame))
}

# https://github.com/geoffjentry/twitteR/blob/c35ff58fcab1e03d0b2bbfa35c0d8814c29315ee/R/utils.R
### Modification ends here ###

#--- 2. You need to read usernames line by line and execute Tweet-collecting script within the loop. Then, create a csv file with all the tweets collected.

names <- file('names.txt', 'r') # Place 'names.txt' file under working directory
lines <- readLines(names, 3) # Specify number of usernames you have in 'names.txt' file
tweetsCombined <- data.frame (text=character(0), created=character(0), id=character(0), screenName=character(0))
for (i in 1:length(lines)){
	userTimeline <- userTimeline(lines[i],n=100, maxID=NULL, sinceID=NULL) # n='number of tweets you want to collect from each user'
	df.userTweets <- twListToDF(userTimeline)
	tweets <- df.userTweets[c("text", "created", "id", "screenName")] # Define properties you want to collect
	tweetsCombined <- rbind(tweetsCombined, tweets)
}
write.csv(tweetsCombined, "fileTweets.csv")
close(names)