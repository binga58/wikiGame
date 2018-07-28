# wiki Game

wiki Game fetches a random page from wikipedia and let users to play fill in the blanks based on that page.

## Approach

* Fetched the most read articles on a random date from wikipedia server.
* Out of fetched articles, A random title is chosen and data is fetched from wikipedia about the title.
* Parsed the json and created random missing words from article.
* On pressing Done points are calculated based on correct answers and shown on next screen.
