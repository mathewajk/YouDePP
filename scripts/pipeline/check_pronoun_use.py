import stanza, json, random, argparse, logging
from sys import argv
from glob import glob
from os import path, makedirs


def main(args):
    dependency_fns = sorted(glob(path.join("corpus", "dependency_corpus", args.caption_type, args.language, args.channel, "*.json")))
    if(len(dependency_fns) == 0):
        print("ERROR: No JSON files found. Did you spell the channel name correctly?")
        return
    process_files(args.channel, args.language, args.caption_type, dependency_fns)


def process_files(channel, language, type, dependency_fns):
    vid_count = 0
    total_pronouns = 0
    total_sentences = 0
    for dependency_fn in dependency_fns:

        video_id = int(path.split(dependency_fn)[1].split('_')[1], 10)

        with open(dependency_fn, "r") as dependencies_in:
            json_data = None
            try:
                json_data = json.load(dependencies_in)
                vid_count += 1
            except:
                continue

            (pron_count, sent_count) = check_pronouns(video_id, stanza.Document(json_data))
            total_pronouns += pron_count
            total_sentences += sent_count
    print(total_pronouns, total_sentences)

def check_pronouns(video_id, doc):
    sent_id = 0
    count_bad = 0
    pronoun_count = 0
    pronoun = 0
    for sentence in doc.sentences:
        for word in sentence.words:
            if word.lemma in ['私','俺','僕','あたし','я']:
                pronoun = 1
                break
        pronoun_count += pronoun
        pronoun = 0
        sent_id += 1
    return pronoun_count, sent_id

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Parse dependencies from a set of subtitle files.')

    parser.add_argument('channel',  type=str, help='a friendly name for the channel')
    parser.add_argument('language',  type=str, help='language code')
    parser.add_argument('caption_type',  default="auto", type=str, help='the type of caption (auto or other)')

    parser.add_argument('--log',    action='store_true', default=False, help='log events to file')

    args = parser.parse_args()

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_dependencies.log'),level=logging.DEBUG)

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN PARSE\n----------")

    main(args)
