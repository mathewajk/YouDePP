from sys import argv
from time import sleep
from os import path, makedirs
from re import sub
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
    except:
        logging.warning("Could not locate 'items' div")
    finally:
        # Scroll to the bottom of the page to load videos
        count = 0
        while (cutoff == -1 or count < cutoff) and scroll_channel(driver, 4):
            count += 1
            print("Loading... ({0})".format(count))

        # Gather urls and metadata
        elements = driver.find_elements_by_xpath('//*[@id="video-title"]')
        return [element.get_attribute('href') for element in elements]


def save_videos(links, info, group=None):
    """Write a scraped list of video links to a file.

    :param links: A list of video URLs
    :param info: A dictionary containing the channel's name, ID, description, bio, and metadata
    :param group: The folder to output the channel info to (default None)
    """

    punc_and_whitespace = "[\s\_\-\.\?\!,;:'\"\\\/]+"
    safe_channel_name = sub(punc_and_whitespace, "", info["channel_name"])

    videos_out_fn = "{0}_{1}_videos.txt".format(safe_channel_name, info["channel_id"])
    info_out_fn = "{0}_{1}_info.txt".format(safe_channel_name, info["channel_id"])

    if group:
        out_dir = path.join("corpus", "channel_data", group)
    else:
        out_dir = path.join("corpus", "channel_data")

    if not path.exists(out_dir):
        makedirs(out_dir)

    videos_out_fn = path.join(out_dir, videos_out_fn)
    info_out_fn = path.join(out_dir, info_out_fn)

    with open(videos_out_fn, 'w') as videos_out, open(info_out_fn, 'w') as info_out:

        for link in links:
            videos_out.write("{0}\t{1}\t{2}\n".format(link, info["channel_name"], info["channel_id"]))

        for key in info.keys():
            info_out.write("{0}\t{1}\n".format(key, info[key]))


def get_info(driver, url):
    """Scrape the channel's description.

    :param driver: A WebDriver object
    :param url: URL of the channel's videos page
    """

    # Load the about page
    driver.get(url)

    info = {"channel_name": "", "description": "", "bio": "", "metadata": ""}

    try:
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, 'ytd-channel-name')))
        info["channel_name"] = driver.find_element(By.CLASS_NAME, "ytd-channel-name").text

    except:
        logging.warning("Could not scrape channel name")

    try:
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, 'description-container')))

        info["description"] = sub("\n", " ", driver.find_element(By.ID, "description-container").text)
        info["bio"] = sub("\n", " ", driver.find_element(By.ID, "bio-container").text)
        info["metadata"] = sub("\n", " ", driver.find_element(By.ID, "details-container").text)

    except:
        logging.warning("Could not scrape About page")

    return info


def process_channel(url, cutoff=-1, group=None, driver=None):
    """Process a channel from a URL

    :param url: Channel URL
    :param cutoff: Limit scrolling to N attempts
    :param group:  Folder name to group channels under
    """

    channel_id = url.split('/')[-1]
    info = {"channel_id": channel_id}

    logging.info("Gathering videos from channel ID: " + channel_id)

    # Run the webdriver
    # TODO: Repetitive for legacy reasons
    if driver:
        info.update(get_info(driver, url + "/about"))
        sleep(1)

        links = get_links(driver, url + "/videos", cutoff)
    else:
        with webdriver.Firefox() as driver:

            info.update(get_info(driver, url + "/about"))
            sleep(1)

            links = get_links(driver, url + "/videos", cutoff)

    logging.info("Found {0} videos".format(str(len(links))))
    save_videos(links, info, group)


def process_channels(channels_fn, cutoff=-1, group=None):
    """Process a list of channels from a file

    :param channels_fn: The file to open
    :param cutoff: Limit scrolling to N attempts
    :param group:  Folder name to group channels under
    """

    with open(channels_fn, 'r') as channels_in:
        with webdriver.Firefox() as driver:
            for line in channels_in:
                line = sub('\s+', '', line.strip('/')) # Handle all whitespace issues?
                process_channel(line, cutoff, group, driver)
                sleep(1)


def handle_single(args):
    """Wrapper for scraping a single channel"""
    process_channel(args.channel, args.cutoff, args.group)


def handle_multiple(args):
    """Wrapper for scraping multiple channels"""
    process_channels(args.file, args.cutoff, args.group)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Scrape video URLs from a YouTube channel.')
    parser.add_argument('-g', '--group', default=None, metavar='NAME', type=str, help='name to group files under (will create a subfolder: channel_data/$group)')
    parser.add_argument('--cutoff', type=int, default=-1, help='maximum number of times to scroll the page')
    parser.add_argument('-l', '--log', action='store_true', default=False, help='log events to file')

    subparsers = parser.add_subparsers(help='process one channel or a list of channels')

    channel_parser = subparsers.add_parser('single', help='process a single channel (see scrape_yt.py single -h for more help)')
    channel_parser.set_defaults(func=handle_single)
    channel_parser.add_argument('channel', type=str, help='URL pointing to the channel\'s main page, e.g. https://www.youtube.com/c/ChannelNameHere')

    list_parser = subparsers.add_parser('multi', help='process a list of channels (see scrape_yt.py multi -h for more help)')
    list_parser.set_defaults(func=handle_multiple)
    list_parser.add_argument('file', type=str, help='file containing a newline-separated list of channel URLs (e.g. https://www.youtube.com/c/ChannelNameHere)')

    args = parser.parse_args()

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_scrape.log'), level=logging.DEBUG)

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN YT SCRAPE\n----------")

    args.func(args)
