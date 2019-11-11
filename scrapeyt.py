from sys import argv
from time import sleep
from os.path import join

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def scroll_channel(driver, pause_time):
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

    # Load the page
    driver.get(url)

    try:
        # Wait for the "items" div to appear
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, 'items')))
    finally:
        # Scroll to the bottom of the page to load videos
        count = 0
        while count < cutoff and scroll_channel(driver, 4):
            count += 1
            print("Loading... ({0})".format(count))

        # Gather urls and metadata
        elements = driver.find_elements_by_xpath('//*[@id="video-title"]')
        return [(element.get_attribute('href'), element.get_attribute('aria-label'))  for element in elements]


def parse_length(yt_string):
    time_string = yt_string.split()

    prev = time_string[0]
    hours, min, sec = (0, 0, 0)
    for item in time_string[1:]:
        if item == '時間':
            hours = prev
        elif item == '分':
            min = prev
        elif item == '秒':
            sec = prev
        else:
            prev = item

    return int(hours) * 60 + int(min) + (int(sec)/60)


def save_videos(links, channel_name):
    with open(join("channel_data", channel_name + '.txt', 'w', encoding="utf-8") as out_file:
        for link in links:
            url, label = link
            title, remainder = label.split(' 作成者: ')

            remainder_noauth = remainder.split('前 ')[1]
            length = parse_length(remainder_noauth)

            out_file.write("{0}\t{1}\t{2:.{round}f}\n".format(title, url, length, round=3))


def main(argv):

    url, cutoff = argv[1:]
    channel_name = url.split('/')[-2]

    print("Gathering videos from channel: " + channel_name)

    # Run the webdriver and get video urls
    driver = webdriver.Firefox()
    links = get_links(driver, url, int(cutoff))
    driver.quit()

    print("Found {0} videos".format(str(len(links))))

    save_videos(links, channel_name)

if __name__ == '__main__':
    main(argv)
