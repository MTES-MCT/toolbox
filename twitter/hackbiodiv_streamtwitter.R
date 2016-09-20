# Chargement des librairies
library(streamR)
library(ROAuth)

# Identifiant de connexion 
consumerKey <- "<clef>"
consumerSecret <- "<secret>"

# Noms des fichiers de sortie & mots clefs recherchés
my_file <- "tweetsFrelon.json"
my_file.csv <- "tweetsFrelon.csv"
my_key <- "frelon,frelons,frelon asiatique,frelons asiatiques,vespa velutina,vespavelutina,asian hornet,asiatischen hornisse,asianhornet"

# Définition de la connexion
my_oauth <- OAuthFactory$new(consumerKey=consumerKey,consumerSecret=consumerSecret,
                             requestURL="https://api.twitter.com/oauth/request_token",
                             accessURL="https://api.twitter.com/oauth/access_token",
                             authURL="https://api.twitter.com/oauth/authorize")
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

# Ecoute sur twitter
filterStream(my_file, track = my_key, timeout = 60, oauth = my_oauth)

# Transformation en data frame
tweets.df <- parseTweets(my_file, verbose = FALSE)

# Enregiistrement d'un fichier csv
write.table(tweets.df, my_file.csv,sep=";")