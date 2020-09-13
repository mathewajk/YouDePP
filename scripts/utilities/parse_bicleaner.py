import stanza, json, argparse, logging
from sys import argv
from glob import glob
from os import path, makedirs, getcwd
from sys import stdout

def main(args):
    corpus_file = args.corpus
    parse(corpus_file, args.language1, args.language2)

def parse(corpus, l1, l2):

    out_path_l1 = path.join("corpus", "bicleaner", l1)
    if not path.exists(out_path_l1):
        makedirs(out_path_l1)

    out_path_l2 = path.join("corpus", "bicleaner", l2)
    if not path.exists(out_path_l2):
        makedirs(out_path_l2)

    nlp_l1 = stanza.Pipeline(lang=l1, use_gpu=True)
    nlp_l2 = stanza.Pipeline(lang=l2, use_gpu=True)

    parsed_sentences = 1
    total_sentences = 1
    with open(corpus, "r") as paracrawl_data, open(path.join(out_path_l1, l1 + '-' + l2 + '_' + l1 + '-parse.jsonl'), 'w') as l1_out, \
         open(path.join(out_path_l2, l1 + '-' + l2 + '_' + l2 + '-parse.jsonl'), 'w') as l2_out:

        l1_buffer = ''
        l2_buffer = ''

        for line in paracrawl_data:
            line = line.strip().split('\t')

            total_sentences  += 1

            if(line[3][-1] not in ["。", "！", "？"]):
                continue

            l1_buffer = l1_buffer + line[2] + '\n'
            l2_buffer = l2_buffer + line[3] + '\n'

            if(parsed_sentences % 150 == 0):

                l1_doc = l1_buffer
                l2_doc = l2_buffer

                # Clear buffers
                l1_buffer = ''
                l2_buffer = ''

                # L1 data
                try:
                    l1_parse = nlp_l1(l1_doc)
                except RecursionError as e:
                    logging.critical("Could not parse {0}: recursion depth exceeded: sentence {0}, language {1}".format(parsed_sentences, l1))
                    break
                except RuntimeError as e:
                    logging.critical("CUDA out of memory! sentence {0}, language {1}".format(parsed_sentences, l1))
                    break

                try:
                    l2_parse = nlp_l2(l2_doc)
                except RecursionError as e:
                    logging.critical("Could not parse {0}: recursion depth exceeded: sentence {0}, language {1}".format(parsed_sentences, l2))
                    break
                except RuntimeError as e:
                    logging.critical("CUDA out of memory! sentence {0}, language {1}".format(parsed_sentences, l2))
                    break

                l1_out.write(json.dumps(l1_parse.to_dict()))
                l2_out.write(json.dumps(l2_parse.to_dict()))
                l1_out.write("\n")
                l2_out.write("\n")

                print("Batch complete: {0}".format(parsed_sentences))

            parsed_sentences += 1
            if(parsed_sentences % 500000 == 0):
                print("Total sentences checked: {0}, total sentences parsed: {1}".format(total_sentences, parsed_sentences))
                return

    return

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Parse dependencies from bicleaner-formatted files.')

    parser.add_argument('corpus',  type=str, help='path to the corpus')
    parser.add_argument('language1',  type=str, help='language code for language 1')
    parser.add_argument('language2',  type=str, help='language code for language 2')
    parser.add_argument('--log',    action='store_true', default=False, help='log events to file')

    args = parser.parse_args()

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_dependencies.log'),level=logging.DEBUG)

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN PARSE\n----------")

    main(args)
