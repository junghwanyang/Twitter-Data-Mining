# MINING TWITTER USER'S TIMELINE USING R (1)
### WRITTEN BY JUNGHWAN YANG (jyang66@wisc.edu) ON SEPTEMBER 24, 2013
### MORE INFORMATION: http://goo.gl/4AP90Q

#--- 1. Install packages and set working directory

install.packages(c("twitteR", "ROAuth", "RCurl"))
library(twitteR);library(ROAuth);library(RCurl)

# Set up a working directory
setwd('/Users/YourWorkingDirectory')

 

#--- 2. Getting a curl certification

download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

 

#--- 3. Setting the certification from Twitter

# Set constant requestURL
requestURL <- "https://api.twitter.com/oauth/request_token"
# Set constant accessURL
accessURL <- "https://api.twitter.com/oauth/access_token"
# Set constant authURL
authURL <- "https://api.twitter.com/oauth/authorize"
# In consumer key field, paste the consumer key token you got from your Twitter developer application.
consumerKey <- "xxxxxxxxxxxxxxxxxxxxxxxx"
# In consumer secret field, paste the access secret token you got from your Twitter developer application.
consumerSecret <- "xxxxxxxxxxxxxxxxxxxxxxxx"

 

#--- 4. Creating the authorization object by calling function OAuthFactory

twitCred <- OAuthFactory$new(consumerKey=consumerKey, consumerSecret=consumerSecret, requestURL=requestURL, accessURL=accessURL, authURL=authURL)



#--- 5. Saving and using certification to connect to Twitter

# Asking for access
twitCred$handshake(cainfo="cacert.pem")

# In your R console you will see the following message instructing you to direct your web browser to the specified URL. There you will get a PIN code which you will have to type in your R console.
# To enable the connection, please direct your web browser to:
# https://api.twitter.com/oauth/authorize?oauth_token=xxxx
# When complete, record the PIN given to you and provide it here: xxxxxx

 

#--- 6. Verify if it works alright

registerTwitterOAuth(twitCred)

 
# If it says "TRUE," you are good to go.
# Save the credential for future use by downloading a Cred file at your default R folder

save(list="twitCred", file="twitteR_credentials")

 
# Resource comes from: https://sites.google.com/site/dataminingatuoc/home/data-from-twitter/r-oauth-for-twitter
 

# We got all we need now. Let's mining Twitter!!!

#--- 1. Load your credential

load("twitteR_credentials")
registerTwitterOAuth(twitCred)

 

#--- 2. Get a particular user's 100 most recent Twitter updates from Twitter.

timeline.User1 <- userTimeline('@username',n=100, maxID=NULL, sinceID=NULL)

 

#--- 3. Save collected data in a dataframe.

df.User1 <- twListToDF(timeline.User1)

 
# Press Enter or ESC if it asks further entry.
 

#--- 4. Extract the properties you want to collect (e.g., username, time, text, location, link, etc.). Here, I chose to save time, user ID, screen name, and tweet texts.

tweets.User1 <- df.User1[c("text", "created", "id", "screenName")]

 

#--- 5. Save as .csv file.

write.csv(tweets.User1, "file.User1.csv")