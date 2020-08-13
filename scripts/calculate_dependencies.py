import stanza, json, random, argparse, logging
from sys import argv
from glob import glob
from os import path, makedirs


def main(args):
    dependency_fns = sorted(glob(path.join("corpus", "dependency_corpus", args.caption_type, args.language, args.channel, "*.json")))
    process_files(args.channel, args.language, args.caption_type, dependency_fns)


def process_files(channel, language, type, dependency_fns):

    dep_path = path.join("corpus", "dependency_counts", type, language, channel)
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

        for dependency_fn in dependency_fns:

            logging.info("Processing: {0}".format(dependency_fn))
            video_id = int(path.split(dependency_fn)[1].split('_')[1], 10)

            with open(dependency_fn, "r") as dependencies_in:
                try:
                    process_dependencies(video_id, stanza.Document(json.load(dependencies_in)), observed_out, optimal_out, random_out)
                except:
                    logging.warning("Could not open {0}".format(video_id))

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
    avg_random_dep = 0

    for i in range(0, 100):

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

        avg_random_dep += dep_total_random

    random_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, (avg_random_dep/100), num_dependencies))

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
        (parent, rel, child) = i
        nodes[child] = {"parent": parent, "child": child, "relation": rel, "children": []}

    forest = []
    for i in dependencies:
        parent, rel, child = i
        node = nodes[child]

        if rel == 'root' or parent.text == 'ROOT': # this should be the Root Node
            forest.append(node)
        else:
            parent = nodes[parent]
            children = parent['children']
            children.append(node)

    return forest


def get_dependency_length(dependency, indices):
    (governor, rel, child) = dependency
    if rel == 'root' or governor.text == 'ROOT':
        return 0
    else:
        return abs(indices[governor.id] - indices[child.id])


def process_dependencies(video_id, doc, observed_out, optimal_out, random_out):
    sent_id = 0
    count_bad = 0
    for sentence in doc.sentences:

        true_dependencies = [dependency for dependency in sentence.dependencies if (dependency[0].upos not in ["punct", "PUNCT"] and dependency[1] not in ["punct", "PUNCT"])]
        num_dependencies = len(true_dependencies)

        if(num_dependencies < 1 or num_dependencies > 40):
            continue

        try:
            dependency_tree = tree(true_dependencies)
        except:
            logging.warning("Tree construction failed for sentence {0} in video {1}".format(sent_id, video_id))
            print(sentence)

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
            logging.critical("{0}-{1}: Observed dependencies shorter than optimal!".format(video_id, sent_id))
            print(sentence)

        process_random(sentence, video_id, sent_id, num_dependencies, dependency_tree, random_out)

        if(dep_total_optimal > dep_total_true):
            count_bad += 1
        if num_dependencies > 1:
            logging.info("Video: {2}, Sentence: {3}, Observed: {0}, Optimal: {1}".format(dep_total_true, dep_total_optimal, video_id, sent_id))

        observed_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_true, num_dependencies))
        optimal_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_optimal, num_dependencies))

        sent_id += 1


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
