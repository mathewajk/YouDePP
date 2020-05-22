import re, logging

from sys import argv, stdout, exit
from argparse import ArgumentParser
from os import path, makedirs, getcwd
from glob import glob
from stanza import Pipeline
from random import shuffle
from emoji import get_emoji_regexp


def remove_emoji(text):
    return get_emoji_regexp().sub(u'', text)


def main(args):

    # Get all .srt files for the specified language and channel
    # Files are sorted numerically by initial number
    subtitles_fns = sorted(glob(path.join("subtitles", args.language, args.channel, "*.srt")), key=get_video_id)
    preprocess_files(args.channel, args.language, subtitles_fns, args.start, args.end)


# Parse the video ID from the filename
# IDs are assumed to be the first component of the filename as delineated by "_"
def get_video_id(video_fn):
    return int(path.split(video_fn)[1].split('_')[0], 10)


# Clean up subtitle files
# Processing differs based on the language specified
def preprocess_files(channel, language, subtitles_fns, start, end):

    out_path = path.join("subtiles_processed_auto", language, channel)

    if not path.exists(out_path):
        makedirs(out_path)


    video_count = 0
    for subtitles_fn in subtitles_fns:
        video_id = get_video_id(subtitles_fn)
        if(video_id < start or (end != -1 and video_id > end)):
            continue

        out_fn = "_".join([channel, str(video_id), "processed", "auto"])

        logging.info("Processing file: {0}".format(subtitles_fn))
        logging.info("Video ID: {0}".format(video_id))
        logging.info("Output file: {0}".format(out_fn))

        with open(subtitles_fn, "r") as subtitles_in:

            if language == 'ja':
                preprocessed_subtitles = list(preprocess_subtitles_ja(subtitles_in))
            elif language == 'ru':
                preprocessed_subtitles = list(preprocess_subtitles_ru(subtitles_in))

            logging.info("Found {0} lines".format(len(preprocessed_subtitles)))

            if len(preprocessed_subtitles) != 0:
                with open(path.join(out_path, out_fn + ".txt"), "w") as subtitles_out:
                    for line in preprocessed_subtitles:
                        subtitles_out.write(line + "\n")

            video_count += 1

    logging.info("Processed {0} files".format(video_count))


def preprocess_subtitles_ru(subtitles):
    for line in subtitles:

        if line and not re.search("^[0-9]", line):

            line = remove_emoji(line.strip())
            line = line.replace(":D", "")
            line = line.replace(":)", "")

            line = re.sub(r'\([^)]*\)', '', line) # Remove parens
            line = re.sub(r'<[^)]*>', '', line)   # Remove HTML
            line = re.sub("[♫♡♥♪→↑↖↓←⇓\(\)\[\]\n]", "", line)
            line = re.sub("[!?]", ".", line)

            if line:
                if(line[-1] != '.' and line[-1] != ','):
                    line += '.'
                no_attr = re.split("[:]", line)
                if len(no_attr) > 1:
                    yield ("".join(no_attr[1:]))
                else:
                    yield line


def preprocess_subtitles_ja(subtitles):
    for line in subtitles:

        line = line.strip()

        if line and not re.search("^[0-9]", line):

                #print("Initial: " + line)

                # Remove emoji
                line = remove_emoji(line)

                # Replace all punctuation except commas
                line = re.sub("[！‼？!?.…]", "。", line)
                line = line.replace("～", "") # Re doesn't recognize ～
                line = line.replace("〜", "") # These are two different chars, believe it or not.
                line = line.replace("、、、", "。") # Special case of ellipses

                # Reomove text within matched parentheticals
                parentheses = ["（[^（）]*）", "〔[^〔〕]*〕", "\([^()]*\)", "\[[^\[\]]*\]", "【[^【】)]*】", "＜[^＜＞)]*＞", "｛[｛｝)]*｝"]
                for paren_type in parentheses:
                    line = re.sub(paren_type, "", line)

                # Remove HTML
                line = re.sub(r'<[^)]*>', '', line)

                if not line:
                    #print("Final:   NA")
                    #input()
                    continue

                # Hacky fix for some troublesome whitespace typos
                attr_typos = [(" ：", "："), (" ）","）"), (" )", ")")]
                for typo, correction in attr_typos:
                    line = line.replace(typo, correction)

                # Remove speaker attributions (NOTE: Depends on above fix)
                line_noattr = re.sub("[^\s　。、]+[）\):：;)≫>]", "。", line)

                # Hacky solution for attributions using 「」
                # Do best to prevent accidentally removing content outside 「」or
                # when the 「」 isn't actually an attibution
                if(line_noattr == line):
                    if line[-1] == "」" or (line.find("「") > -1 and line.find("」") == -1):
                        line = re.sub("^[^\s]+「", "。", line).replace("」", "")
                else:
                    line = line_noattr

                # Remove action text
                line = re.sub("[（\(](.*)", "", line)

                # Remove any stray special characters
                line = re.sub("[　<>・･‥／☆\s♫♡♥♪→↑↖↓←”✖wｗWＷ※⇓⇒\~()（）【】《》✖\[\]\n]", "", line)

                # Fixes for multiple & initial periods
                line = re.sub("。+", "。", line)
                line = re.sub("^。", "", line)

                if line:

                    if(line[-1] != '。' and line[-1] != '、'):
                        line += '。'

                    #print("Final:   " + line)
                    #input()

                    yield line
                else:
                    #print("Final:   NA")
                    #input()
                    continue


if __name__ == '__main__':

    parser = ArgumentParser(description='Parse dependencies from a set of subtitle files.')

    parser.add_argument('channel', type=str, help='a friendly name for the channel')
    parser.add_argument('language', type=str, help='language code')

    parser.add_argument('-s', '--start', default=1, type=int, help='video to start from')
    parser.add_argument('-e', '--end', default=-1, type=int, help='video to stop at')

    parser.add_argument('--log', action='store_true', default=False, help='log events to file')

    args = parser.parse_args()

    if args.end != -1 and args.start > args.end:
        parser.print_help()
        print("ERROR: -s/--start: must not exceed end value")
        exit(1)

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_dependencies.log'),level=logging.DEBUG)

    logging.info("Call: {0}".format(args))

    main(args)
