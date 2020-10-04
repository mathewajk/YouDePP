import stanza, json, argparse, logging
from sys import argv
from glob import glob
from os import path, makedirs, getcwd
from sys import stdout


def main(args):
    type = "json"
    fns = sorted(glob(path.join(args.corpus, "*.json")))
    if(len(fns) == 0):
        fns = sorted(glob(path.join(args.corpus, "*.jsonl")))
        if(len(fns) == 0):
            print("ERROR: No JSON(L) files found. Did you specify the correct path?")
            return 1
        else:
            type = "jsonl"

    length = 0
    for fn in fns:
        with open(fn) as file_in:
            if type == "json":
                try:
                    json_data = json.load(file_in)
                    length += len(stanza.Document(json_data).sentences)
                except:
                    continue
            else:
                for line in file_in:
                    try:
                        json_data = json.loads(line)
                        length += len(stanza.Document(json_data).sentences)
                    except:
                        continue
    print("Found {0} sentences".format(length))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Check the number of sentences parsed, because I am dumb.')

    parser.add_argument('corpus',  type=str, help='path to the files to check')
    parser.add_argument('--log',    action='store_true', default=False, help='log events to file')

    args = parser.parse_args()

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_dependencies.log'),level=logging.DEBUG)

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN PARSE\n----------")

    main(args)
