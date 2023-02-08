# rss-generator
Scrape sites into rss feeds

- uses [mkfeed](https://github.com/dburic/mkfeed) to parse html into an rss file
    - since that has not been updated for a while, `mkfeed.py.patch` makes it python3 compatible
- uses GithubActions to periodically scrape the site(s)
- uses Github Pages to provide the RSS-Feed
