import stanza, random, re, argparse, logging, emoji
from sys import argv
from glob import glob
from os import path, makedirs, getcwd
from sys import stdout


def remove_emoji(text):
    return emoji.get_emoji_regexp().sub(u'', text)


def main(args):
    subtitles_fns = sorted(glob(path.join("corpus", "processed_subtitles", args.caption_type, args.language, args.channel, "*.srt")))
    print(path.join("corpus", "processed_subtitles", args.caption_type, args.language, args.channel, "*.srt"))
    print(subtitles_fns)

    nlp = stanza.Pipeline(lang=args.language)
    process_files(nlp, args.channel, args.language, args.caption_type, subtitles_fns)


def process_files(nlp, channel, language, type, subtitles_fns):

    dep_path = path.join("corpus", "dependencies", type, language, channel)
    if not path.exists(dep_path):
        makedirs(dep_path)

    observed_fn = path.join(dep_path, channel + "_observed_dependencies.csv")
    optimal_fn  = path.join(dep_path, channel + "_optimal_dependencies.csv")
    random_fn   = path.join(dep_path, channel + "_random_dependencies.csv")

    with open(observed_fn, "w") as observed_out, \
         open(optimal_fn,  'w') as optimal_out,  \
         open(random_fn,   'w') as random_out:

        out_files = (observed_out, optimal_out, random_out)
        header = "video_id, sentence_id, dep_length, total_length\n"

        for f in out_files:
            f.write(header)

        vid_count = 0

        for subtitles_fn in subtitles_fns:

            logging.info("Processing: {0}".format(subtitles_fn))
            video_id = int(path.split(subtitles_fn)[1].split('_')[1], 10)

            with open(subtitles_fn, "r") as subtitles_in:

                preprocessed_subtitles = list(subtitles_in)

                print(subtitles_fn)
                print(video_id)
                #fprint("".join(preprocessed_subtitles))

                logging.info("Found {0} lines".format(len(preprocessed_subtitles)))

                nlp_subtitles = None
                try:
                    nlp_subtitles = nlp("".join(preprocessed_subtitles))
                except RecursionError as e:
                    logging.warning("Could not parse {0}: recursion depth exceeded".format(video_id))
                    continue
                except:
                    logging.warning("Could not parse {0}: an unexpected error occurred".format(video_id))
                    continue
                finally:
                    process_dependencies(video_id, nlp_subtitles, observed_out, optimal_out, random_out)
                    vid_count += 1

    logging.info("Processed {0} files".format(vid_count))


def linearize_optimal(node, right=True):

    if not len(node['children']):
        return [(node['parent'], node['relation'], node['child'])]

    else:

        sorted_children = node['children']
        sorted_children.sort(key=weight, reverse=True)
        chunk = [(node['parent'], node['relation'], node['child'])]

        root_pos = 0
        for i in range(0, len(sorted_children)):
            weight_cur = weight(sorted_children[i])
            if (i % 2 and right) or (not i % 2 and not right): # Add the largest child to the right of the parent, then swap directions
                chunk.insert(root_pos + 1, linearize_optimal(sorted_children[i], False))
            else: # Add largest to left and swap
                chunk.insert(root_pos, linearize_optimal(sorted_children[i], True))
                root_pos = root_pos + 1

        return chunk

def linearize_random(node):

    if not len(node['children']):
        return [(node['parent'], node['relation'], node['child'])]

    else:
        chunk = []
        for child in node['children']: # Randomize each child and append it
            chunk.append(linearize_random(child))
        chunk.append((node['parent'], node['relation'], node['child']))
        random.shuffle(chunk)

        return chunk


def process_random(sentence, video_id, sent_id, num_dependencies, dependency_tree, random_out):

    min = 1000
    max = 0

    for i in range(0, 1):

        dep_total_random = 0
        random_indices = {}

        random_dependencies =  list(iter_flatten(linearize_random(dependency_tree[0])))
        for j in range (0, len(random_dependencies)):
            random_indices.update({random_dependencies[j][2].id: j + 1})

        for random_dep in random_dependencies:
            dep_total_random += get_dependency_length(random_dep, random_indices)

        if dep_total_random > max:
            max = dep_total_random
        if dep_total_random < min:
            min = dep_total_random

        random_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_random, num_dependencies))

    if num_dependencies > 5:
        logging.info("Range of random deps: [{0}, {1}]".format(min, max))


def weight(node):
    if not len(node['children']):
        return 1
    return 1 + sum(map(weight, node['children']))


def iter_flatten(iterable):
  it = iter(iterable)
  for e in it:
    if isinstance(e, list):
      for f in iter_flatten(e):
        yield f
    else:
      yield e

def tree(dependencies):
    nodes={}
    for i in dependencies:
        parent, rel, child = i
        nodes[child] = {"parent": parent, "child": child, "relation": rel, "children": []}

    forest = []
    for i in dependencies:
        parent, rel, child = i
        node = nodes[child]

        if rel == 'root': # this should be the Root Node
                forest.append(node)
        else:
            parent = nodes[parent]
            children = parent['children']
            children.append(node)
    return forest


def get_dependency_length(dependency, indices):
    (governor, rel, child) = dependency
    if rel == 'root':
        return 0
    else:
        return abs(indices[governor.id] - indices[child.id])


def process_dependencies(video_id, doc, observed_out, optimal_out, random_out):
    sent_id = 0
    count_bad = 0
    for sentence in doc.sentences:

        true_dependencies = [dependency for dependency in sentence.dependencies if dependency[1] not in ["punct"]]
        num_dependencies = len(true_dependencies)

        if(num_dependencies < 1 or num_dependencies > 40):
            continue

        try:
            dependency_tree = tree(true_dependencies)
        except:
            logging.warning("Tree construction failed for sentence {0}".format(sent_id))
            continue

        optimal_dependencies = list(iter_flatten(linearize_optimal(dependency_tree[0])))
        dependencies = list(zip(true_dependencies, optimal_dependencies))

        true_indices, optimal_indices = ({}, {})
        for i in range (0, len(dependencies)):
            true_indices.update({true_dependencies[i][2].id: i + 1})
            optimal_indices.update({optimal_dependencies[i][2].id: i + 1})

        dep_total_true, dep_total_optimal = (0, 0)

        for (true_dep, optimal_dep) in dependencies:
            dep_total_true += get_dependency_length(true_dep, true_indices)
            dep_total_optimal += get_dependency_length(optimal_dep, optimal_indices)

        if(dep_total_optimal > dep_total_true):
            logging.critical("Observed dependencies shorter than optimal!")

        process_random(sentence, video_id, sent_id, num_dependencies, dependency_tree, random_out)

        if(dep_total_optimal > dep_total_true):
            count_bad += 1
        if num_dependencies > 1:
            logging.info("Video: {2}, Sentence: {3}, Observed: {0}, Optimal: {1}".format(dep_total_true, dep_total_optimal, video_id, sent_id))

        observed_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_true, num_dependencies))
        optimal_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_optimal, num_dependencies))

        sent_id += 1

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
                line = line.replace("、、、", "。") # Special case of ellipses

                # Reomove text within matched parentheticals
                parentheses = ["（[^（）]*）", "〔[^〔〕]*〕", "\([^()]*\)", "\[[^\[\]]*\]", "【[^【】)]*】"]
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
                line_noattr = re.sub("[^\s　。、]+[）\):：)]", "。", line)

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
