from sys import argv
from time import sleep
from os import path
import logging, argparse

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def scroll_channel(driver, pause_time):
    """Scroll the channel to load more videos.

    :param driver: A WebDriver object
    :param pause_time: Time to wait before scrolling again

    :return continue: 1 if scroll was successful, 0 if page bottom has been reached
    """

    # Get scroll height
    last_height = driver.execute_script('return document.querySelector("#page-manager").scrollHeight')

    # Scroll down to bottom
    driver.execute_script('window.scrollTo(0,document.querySelector("#page-manager").scrollHeight);')

    # Wait to load page
    sleep(pause_time)

    # Calculate new scroll height and compare with last scroll height
    new_height = driver.execute_script('return document.querySelector("#page-manager").scrollHeight')
    if new_height == last_height: # End of list
        return 0
    return 1


def get_links(driver, url, cutoff):
    """Scrape the URLs from a YouTube channel.

    :param driver: A WebDriver object
    :param url: URL of the channel's videos page
    :param cutoff: Limit scrolling to N attempts

    :return continue: 1 if scroll was successful, 0 if page bottom has been reached
    """

    # Load the page
    driver.get(url)

    try:
        # Wait for the "items" div to appear
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, 'items')))
    finally:
        # Scroll to the bottom of the page to load videos
        count = 0
        while (cutoff == -1 or count < cutoff) and scroll_channel(driver, 4):
            count += 1
            print("Loading... ({0})".format(count))

        # Gather urls and metadata
        elements = driver.find_elements_by_xpath('//*[@id="video-title"]')
        return [(element.get_attribute('href'), element.get_attribute('aria-label'))  for element in elements]


def save_videos(links, language, channel_name):
    """Scrape the URLs from a YouTube channel.

    :param links: A list of video URLs
    :param language: The language code corresponding to the channel's audio
    :param channel_name: The name of the channel
    """

    with open(path.join("corpus", "channel_data", language, channel_name + '.txt'), 'w', encoding="utf-8") as out_file:
        for link in links:
            url, label = link
            out_file.write("{0}\t{1}\n".format(url, label))


def main(args):

    channel_name = args.url.split('/')[-2]

    logging.info("Gathering videos from channel: " + args.channel)

    # Run the webdriver and get video urls
    driver = webdriver.Firefox()
    links = get_links(driver, args.url, args.cutoff)
    driver.quit()

    logging.info("Found {0} videos".format(str(len(links))))

    save_videos(links, args.language, args.channel)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Scrape video URLs from a YouTube channel.')

    parser.add_argument('url',      type=str, help='URL pointing to the channel\'s videos')
    parser.add_argument('channel',  type=str, help='a friendly name for the channel')
    parser.add_argument('language', type=str, help='language code')

    parser.add_argument('-c', '--cutoff', type=int, default=-1, help='maximum number of times to scroll the page')
    parser.add_argument('-l', '--log', action='store_true', default=False, help='log events to file')

    args = parser.parse_args()

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_scrape.log'),level=logging.DEBUG)

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN YT SCRAPE\n----------")

    main(args)
