import stanza, json, random, argparse, logging
from sys import argv
from glob import glob
from os import path, makedirs


def main(args):
    process_file(args.input, args.language, args.corpus)


def process_file(input, language, corpus):

    dep_path = path.join("corpus", "dependency_counts", "ud", language)
    if not path.exists(dep_path):
        makedirs(dep_path)

    observed_fn = path.join(dep_path, "_".join([language, corpus, "observed_dependencies.csv"]))
    optimal_fn  = path.join(dep_path, "_".join([language, corpus, "optimal_dependencies.csv"]))
    random_fn   = path.join(dep_path, "_".join([language, corpus, "random_dependencies.csv"]))

    with open(observed_fn, "w") as observed_out, \
         open(optimal_fn,  'w') as optimal_out,  \
         open(random_fn,   'w') as random_out:

        out_files = (observed_out, optimal_out, random_out)
        header = "sentence_id, dep_length, total_length\n"

        for f in out_files:
            f.write(header)

        with open(input, "r") as dependencies_in:
            process_dependencies(dependencies_in, observed_out, optimal_out, random_out)


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
            if (i % 2 and right) or (not i % 2 and not right): # Add the largest child to the right of the parent, then swap sides
                chunk.insert(root_pos + 1, linearize_optimal(sorted_children[i], False))
            else: # Add largest child to left of the parent, then swap sides
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


def process_random(sentence, sent_id, num_dependencies, dependency_tree, random_out):

    min = 1000
    max = 0
    avg_random_dep = 0

    for i in range(0, 10):

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
        random_out.write("{0}, {1}, {2}\n".format(sent_id, dep_total_random, num_dependencies))

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
        try:
            dist = abs(indices[governor.id] - indices[child.id])
        except:
            print(indices)
            print("Governor: {0}; Child:{1}".format(governor.id, child.id))

        return abs(indices[governor.id] - indices[child.id])

def get_true_dependencies(dependencies, sent_id):
    true_dependencies = []
    for dependency in dependencies:
        if dependency[1] not in ["punct", "PUNCT"]:
            if(dependency[0].text in ["root", "ROOT"]):
                if(dependency[2].upos in ["punct", "PUNCT"]):
                    logging.warning("{0} ROOT is PUNCT".format(sent_id))
                    return([])
            true_dependencies.append(dependency)
    return true_dependencies

def process_dependencies(dependencies_in, observed_out, optimal_out, random_out):


    count_bad = 0
    sent_id = -1
    current_sentence = []

    for line in dependencies_in:

        if line[0] == '#':
            continue

        line = line.strip().split('\t')

        if len(line) > 1:
            current_sentence.append(line)
            continue

        sent_id += 1
        sentence = current_sentence
        current_sentence = []
        conll_dict = {}

        try:
            conll_dict = stanza.utils.conll.CoNLL.convert_conll([sentence])
        except:
            logging.error("Could not convert sentence {0} to Dictionary".format(sent_id))
            continue

        try:
            sentence = stanza.Document(conll_dict).sentences[0]
        except:
            logging.error("Could not convert sentence {0} to Document".format(sent_id))
            continue

        true_dependencies = get_true_dependencies(sentence.dependencies, sent_id)
        num_dependencies = len(true_dependencies)

        if(num_dependencies < 1):
            continue

        try:
            dependency_tree = tree(true_dependencies)
        except:
            logging.error("Tree construction failed for sentence {0}".format(sent_id))
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
            logging.critical("Sentence {0}: Observed dependencies ({1}) shorter than optimal ({2})!".format(sent_id, dep_total_true, dep_total_optimal))
            count_bad += 1
            continue

        process_random(sentence, sent_id, num_dependencies, dependency_tree, random_out)

        observed_out.write("{0}, {1}, {2}\n".format(sent_id, dep_total_true, num_dependencies))
        optimal_out.write("{0}, {1}, {2}\n".format(sent_id, dep_total_optimal, num_dependencies))


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Parse dependencies from a set of subtitle files.')

    parser.add_argument('input',  type=str, help='Path to .conll file')
    parser.add_argument('language',  type=str, help='Language code')
    parser.add_argument('corpus',  type=str, help='Corpus acronym')
    parser.add_argument('--log',    action='store_true', default=False, help='log events to file')

    args = parser.parse_args()

    if(args.log):
        logging.basicConfig(filename=(args.channel + '_dependencies.log'),level=logging.DEBUG)

    logging.info("Call: {0}".format(args))
    logging.info("BEGIN PARSE\n----------")

    main(args)
