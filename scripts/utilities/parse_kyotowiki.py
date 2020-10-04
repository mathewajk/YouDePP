import stanza, json, argparse, logging
from sys import argv
from glob import glob
from os import path, makedirs, getcwd
from sys import stdout
import xml.dom.minidom


def main(args):
    wiki_fns = sorted(glob(path.join(args.corpus, "**", "*.xml")))
    if(len(wiki_fns) == 0):
        print("ERROR: No XML files founds. Did you specify the correct path?")
        return

    nlp_ja = stanza.Pipeline(lang="ja", dir=path.join("/mnt", "d", "tools", "stanza_resources"), use_gpu=True)
    nlp_en = stanza.Pipeline(lang="en", dir=path.join("/mnt", "d", "tools", "stanza_resources"), use_gpu=True)
    parse_files(nlp_ja, nlp_en, wiki_fns)


def parse_files(nlp_ja, nlp_en, wiki_fns):

    dep_path = path.join("corpus", "parallel_data", "kyoto")
    total_len_en = 0
    total_len_ja = 0

    if not path.exists(dep_path):
        makedirs(path.join(dep_path, "ja"))
        makedirs(path.join(dep_path, "en"))

    for wiki_fn in wiki_fns:
        file_id = path.split(wiki_fn)[-1].split(".")[0]
        print("Processing {0}".format(file_id))
        (ja_len, en_len) = parse_file(nlp_ja, nlp_en, wiki_fn, file_id, dep_path)
        total_len_en += en_len
        total_len_ja += ja_len
        print("Running total: JA {0}; EN {1}".format(total_len_ja, total_len_en))

    print("FINAL RESULTS: Parsed {0} Japanese sentences and {1} English sentences.".format(total_len_ja, total_len_en))

def get_pair(sen):

    ja_sen = ''
    en_sen = ''

    try:
        ja_sen = sen.getElementsByTagName("j")[0].childNodes[0].data
    except IndexError:
        print("WARNING: No Japanese sentence found! Skipping sentence pair.")
        return((' ', ' '))

    try:
        en_sen = sen.getElementsByTagName("e")[0].childNodes[0].data
    except IndexError:
        print("WARNING: No English translation found! Skipping sentence pair.")
        return((' ', ' '))

    return((ja_sen, en_sen))

def parse_file(nlp_ja, nlp_en, wiki_fn, file_id, dep_path):

    dependencies_fn_ja = path.join(dep_path, "ja", "{0}_ja_dependencies.json".format(file_id))
    dependencies_fn_en = path.join(dep_path, "en", "{0}_en_dependencies.json".format(file_id))

    with open(wiki_fn, "r") as wiki_in, open(dependencies_fn_ja, "w") as dependencies_out_ja, open(dependencies_fn_en, "w") as dependencies_out_en:

        wiki_doc = None
        try:
            wiki_doc = xml.dom.minidom.parse(wiki_fn).documentElement
        except xml.parsers.expat.ExpatError as e:
            logging.critical("Could not parse file {0}".format(wiki_fn))
            return (0, 0)

        ja_en_pairs = [get_pair(sen) for sen in wiki_doc.getElementsByTagName("sen")]

        ja_doc = ''
        en_doc = ''

        for ja_sen, en_sen in ja_en_pairs:
            if ja_sen[-1] in ["。", "！", "？"]:
                ja_doc += ja_sen
                en_doc += en_sen + " "

        ja_parse = None
        en_parse  = None
        try:
            ja_parse = nlp_ja(ja_doc)
            en_parse = nlp_en(en_doc)
        except RecursionError as e:
            logging.critical("Could not parse {0}: recursion depth exceeded".format(file_id))
            return (0, 0)
        except RuntimeError:
            logging.critical("CUDA out of memory!".format(file_id))
            return (0, 0)
        except IndexError:
            logging.critical("Stanza encountered an error processing the batch".format(file_id))
            return (0, 0)

        json.dump(ja_parse.to_dict(), dependencies_out_ja)
        json.dump(en_parse.to_dict(), dependencies_out_en)

    print("Parsed {0} Japanese sentences and {1} English sentences.".format(len(ja_parse.sentences), len(en_parse.sentences)))
    return (len(ja_parse.sentences), len(en_parse.sentences))


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Parse dependencies from the Kyoto Wikipedia corpus.')

    parser.add_argument('corpus',  type=str, help='path to the corpus')
    parser.add_argument('--log',    action='store_true', default=False, help='log events to file')

    args = parser.parse_args()

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_dependencies.log'),level=logging.DEBUG)

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN PARSE\n----------")

    main(args)
