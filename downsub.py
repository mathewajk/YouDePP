import requests
from os.path import exists, join
from os import makedirs, getcwd
from time import sleep
from sys import argv
from bs4 import BeautifulSoup

def write_subs(url, title, channel, type):
    subs = requests.get(url)
    with open(join("subtitles", channel, title.replace("/", "-") + "." + type.lower()), 'wb') as outfile:
        outfile.write(subs.content)

def main(argv):
    try:
        file, channel, type, language = argv[1:]
    except:
        print("Usage: [url file] [channel] [subtitle filetype] [language]")
        return 0

    cwd = getcwd()
    if not exists(join(cwd, channel)):
        makedirs(join(cwd, channel))

    with open(file, "r") as video_file:
        print("Processing videos from channel {0} in file {1}".format(channel, file))
        print("Looking for subs in {0} format and in language {1}".format(type, language))

        found_count = 0
        total_count = 0
        total_time = 0.0

        for line in video_file:
            total_count += 1
            if total_count % 50 == 0:
                print("Processed {0} URLs...".format(total_count))
            title, url, time = line.strip('\n').split("\t")

            sub_downpage = requests.get("https://downsub.com/?url=" + url)
            soup = BeautifulSoup(sub_downpage.content, 'html.parser')

            # Look for language in the subtitle region (delimited by "Or translate from <b>English</b> into:")
            try:
                language_div = soup.find('b', text="English").find_previous('div', text=language)
            except AttributeError as e: # No subtitles
                continue

            if language_div is not None:
                print("Manual subs found for {0} (title: {1})".format(url, title))
                found_count += 1

                # The element before the language name contains subtitle links
                download_tags = language_div.previous_sibling

                # <a> elements contain the url, <span> elements contain the file type
                download_links = [tag.get('href') for tag in download_tags.find_all('a')]
                download_types = [tag.next_element for tag in download_tags.find_all('span', class_='badge')]
                download_dict = dict(zip(download_types, download_links))

                # Add video length to total sub time
                total_time += float(time.strip('\n'))

                # Download the subtitles
                write_subs(download_dict[type], title, channel, type)

            sleep(5) # Don't flood the server

        print("Found {0} subtitled videos (out of {1} videos) totaling {2} minutes".format(found_count, total_count, total_time))

if __name__ == '__main__':
    main(argv)
