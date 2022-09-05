

cleantext <- function(text) {
  # Set the text to lowercase
  text <- tolower(text)
  # Remove mentions, urls, emojis, numbers, punctuations, etc.
  text <- gsub("@\\w+", "", text)
  text <- gsub("https?://.+", "", text)
  text <- gsub("\\d+\\w*\\d*", "", text)
  text <- gsub("#\\w+", "", text)
  text <- gsub("[^\x01-\x7F]", "", text)
  text <- gsub("[[:punct:]]", " ", text)
  # Remove spaces and newlines
  text <- gsub("\n", " ", text)
  text <- gsub("^\\s+", "", text)
  text <- gsub("\\s+$", "", text)
  text <- gsub("[ |\t]+", " ", text)
  text
}


cleantext("Hello Orqui! I f'n #loveit 😀")

cleantext("Hello man! #loveit 😀")

cleantext("The dude johnny@streamlit.eu is a a$$hole")
