---
title: "Scraping your banking data with Selenium"
layout: post
published: true
---

While working on [Miser](https://github.com/jamesob/Miser), I wanted
programmatic access to my most recent credit-card transactions. Since Chase
doesn't have an API for this, I had to resort to Selenium, a package for
programmatic browser control.

I was fairly impressed when I first ran the [WebDriver
demo](http://seleniumhq.org/docs/03_webdriver.html#introducing-the-selenium-webdriver-api-by-example)
--- the browser was being automatically controlled by a Python script, and I
could see the whole thing happening. The possible applications are numerous and
exciting.

Anyway, I've come up with a working scraper, attached below and in [this
gist](https://gist.github.com/2819803). Though it is specific to Chase
accounts, this should give you a good idea of how to scrape your own data from
the financial institution of your choice.

{% highlight python%}
from selenium import webdriver
import time


def get_chase_amazon_driver(username, password):
    """Return a logged-in Chase Amazon card selenium driver instance."""
    driver = webdriver.Firefox()
    driver.get("http://www.chase.com")

    time.sleep(2)

    inputElement = driver.find_element_by_id("usr_name")
    inputElement.send_keys(username)

    pwdElement = driver.find_element_by_id("usr_password")
    pwdElement.send_keys(password)

    pwdElement.submit()
    return driver


def _goto_link(driver, text):
    """Follow a link with a WebDriver."""
    l = driver.find_element_by_partial_link_text(text)
    driver.get(l.get_attribute('href'))


def get_recent_activity_rows(chase_driver):
    """Return the 25 most recent CC transactions, plus any pending
    transactions.

    Returns:
        A list of lists containing the columns of the Chase transaction list.
    """
    _goto_link(chase_driver, "See activity")
    time.sleep(10)

    rows = chase_driver.find_elements_by_css_selector("tr.summary")
    trans_list = []

    for row in rows:
        tds = row.find_elements_by_tag_name('td')
        tds = tds[1:]  # skip the link in first cell
        trans_list.append([td.text for td in tds])

    return trans_list


def get_activity(username, password):
    """For a given username, retrieve recent account activity for
    a Chase CC."""
    rows = None
    d = get_chase_amazon_driver(username, password)
    time.sleep(8)

    try:
        rows = get_recent_activity_rows(d)
    except Exception, e:
        print e
    finally:
        d.quit()

    return rows

if __name__ == '__main__':
    import getpass

    uname = raw_input("Username: ")
    pwd = getpass.getpass()

    print get_activity(uname, pwd)
{% endhighlight %}
