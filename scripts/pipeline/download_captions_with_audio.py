import argparse, logging
from pytube import YouTube
from pytube import exceptions
from pytube import helpers

from os import makedirs, getcwd, path, rename
from time import sleep
from sys import argv
import csv

def write_subs(video, id, url, subtitles, language, identifier):

    if not path.exists(path.join("corpus", "raw_subtitles", identifier, language)):
        makedirs(path.join("corpus", "raw_subtitles", identifier, language))

    with open(path.join("corpus", "raw_subtitles", identifier, language, video.author + '_' + str(id) + ".srt"), 'w') as outfile:

        try:
            outfile.write(subtitles.generate_srt_captions())
        except KeyError:
            logging.critical("Video {0}: Could not parse XML for {1} ({2})".format(id, url, video.title))


def write_sound(video, id, identifier):

    audio = video.streams.filter(mime_type="audio/mp4").first()
    audio.download(path.join("corpus", "audio", identifier))

    filename_base = helpers.safe_filename(video.title) + ".mp4"
    rename(path.join("corpus", "audio", identifier, filename_base), path.join("corpus", "audio", identifier, '{0}_{1}_{2}'.format(video.author, id, filename_base)))

def get_subs(video, url, id, language, identifier):

    caption_dict = {caption.name: caption for caption in video.captions}
    print(caption_dict.keys())

    count = 0
    for key in caption_dict.keys():

        if language in key:
            write_subs(video, id, url, caption_dict[key], key, identifier)
            print(key)
            count += 1

    return count


def main(args):

    if not path.exists(path.join("corpus", "raw_subtitles", args.identifier)):
        makedirs(path.join("corpus", "raw_subtitles", args.identifier))

    if not path.exists(path.join("corpus", "logs")):
        makedirs(path.join("corpus", "logs"))

    if(args.r):
        print("Resuming from video {0}".format(args.r))

    # Metadata
    found_count, total_count, total_time = (0, 0, 0)

    channel_dict = {}

    with open(path.join("corpus", "channel_data", args.identifier, args.file), "r") as video_file, open(path.join("corpus", "logs", args.identifier + '_log.csv'), 'w') as log_file:

        # Prepare writer for writing video data
        log_writer = csv.DictWriter(log_file, fieldnames=["author", "id", "title", "description", "keywords", "length", "publish_date", "views", "rating"])
        log_writer.writeheader()

        for line in list(video_file)[args.r:]:

            # Get URL and title
            url, label = line.strip('\n').split("\t")

            # Try to load the video
            try:
                video = YouTube(url)
            except KeyError as e:
                logging.warning("Video {0}: Could not retrieve URL ({1})".format(id, url))
                continue
            except exceptions.VideoUnavailable as e:
                logging.warning("Video {0}: Video unavailable ({1})".format(id, url))
                continue
            except:
                logging.critical("Video {0}: An unexpected error occured ({1})".format(id, url))
                continue


            metadata = {
                "author": video.author,
                "title": video.title,
                "description": video.description.replace('\n', ' '),
                "keywords": video.keywords,
                "length": video.length,
                "publish_date": video.publish_date,
                "views": video.views,
                "rating": video.rating
            }

            if metadata["author"] not in channel_dict.keys():
                channel_dict.update({metadata["author"]: 0})
            channel_dict[metadata["author"]] = channel_dict[metadata["author"]] + 1

            id = channel_dict[metadata["author"]]
            metadata.update({"id": id})

            subtitles = get_subs(video, url, id, args.language, args.identifier)

            if args.audio:
                write_sound(video, id, args.identifier)

            if subtitles:
                log_writer.writerow(metadata)

            # Be considerate!
            sleep(1)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Download available manual subtitles from a list of YouTube videos.')

    parser.add_argument('file',       type=str, help='a file containing the URLs to scrape')
    parser.add_argument('identifier', type=str, help='identifier for dataset')

    parser.add_argument('--r',      type=int, metavar='N', nargs='?', default=0, help='resume downloading from Nth video')
    parser.add_argument('--s',      type=int, metavar='S', nargs='?', default=-1, help='stop after N subtitles')

    parser.add_argument('--audio', '-a', action='store_true', default=False, help='download audio')
    parser.add_argument('--video', '-v', action='store_true', default=False, help='download video')
    parser.add_argument('--language', '-l', type=str, default="", help='specify a language for caption downloads')

    args = parser.parse_args()

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN DOWNLOAD\n----------")

    main(args)
