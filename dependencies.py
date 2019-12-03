import stanfordnlp, random, re
from sys import argv
from glob import glob
from os.path import exists, join
from os import makedirs, getcwd

def main(channel):
    subtitle_files = glob(join("subtitles", channel, "*.srt"))
    nlp = stanfordnlp.Pipeline(lang="ja")
    process_files(channel, subtitle_files, nlp)

def process_files(channel, subtitle_files, nlp):

    dep_path = join("dependencies", channel)
    if not exists(dep_path):
        makedirs(dep_path)

    observed_fn = join(dep_path, channel + "_observed_dependencies.csv")
    optimal_fn  = join(dep_path, channel + "_optimal_dependencies.csv")
    random_fn   = join(dep_path, channel + "_random_dependencies.csv")

    with open(observed_fn, "w") as observed_out,
         open(optimal_fn,  'w') as optimal_out,
         open(random_fn,   'w') as random_out:

        out_files = (observed_out, optimal_out, random_out)
        header = "video_id, sentence_id, dep_length, total_length\n"

        for f in out_files:
            f.write(header)

        video_id = 0
        for subtitle_fn in subtitle_files:
            with open(subtitle_fn, "r") as subtitle_in:
                print("Processing: {0}".format(subtitle_in))

                video_id += 1
                processed_lines = list(process_lines(subtitle_in))
                print("Found {0} lines".format(len(processed_lines)))

                if len(processed_lines) != 0:
                    nlp_processed = nlp("。".join(processed_lines))
                    process_dependencies(video_id, nlp_processed, observed_out, optimal_out, random_out)

    print("Processed {0} files".format(vid_count))

def linearize_optimal(node, indent="", right = True, n="0", verbose=False):
    if not len(node['children']):
        if(verbose):
            print(indent + n + " Found terminal node: {0}".format(node['child']))
        return [(node['parent'], node['relation'], node['child'])]
    else:

        chunk = [(node['parent'], node['relation'], node['child'])]
        root_pos = 0

        sorted_children = node['children']
        sorted_children.sort(key=weight, reverse=True)

        total_weight = weight(node)
        weight_left = 0
        weight_right = 0

        if verbose:
            print(indent + n + " Found intermediate node {0} with total weight {1}".format(node['child'], total_weight))

        for i in range(0, len(sorted_children)):
            weight_cur = weight(sorted_children[i])
            if (i % 2 and right) or (not i % 2 and not right):
                # Add the largest child to the right of the parent, then swap directions
                chunk.insert(root_pos + 1, linearize_optimal(sorted_children[i], indent + "  ", False, n + "." + str(i), verbose))
                weight_right += weight_cur
                if verbose:
                    print(indent + n + " Added child of weight {0} to RIGHT".format(weight_cur))
            else: # Add largest to left and swap
                chunk.insert(root_pos, linearize_optimal(sorted_children[i], indent + "  ", True,  n + "." + str(i), verbose))
                if verbose:
                    print(indent + "Added child of weight {0} to LEFT".format(weight_cur))
                weight_left += weight_cur
                root_pos = root_pos + 1

            if verbose:
                print(indent + n + " Current left weight: {0} Current right weight: {1}".format(weight_left, weight_right))
                print()

        return chunk

def linearize_random(node):

    if not len(node['children']):
        return [(node['parent'], node['relation'], node['child'])]

    else:
        chunk = []
        random_children = node['children']
        random.shuffle(random_children) # Order children randomly

        for child in random_children: # Randomize each child and append it
            chunk.append(linearize_random(child))
        chunk.insert(random.randint(0, len(chunk)), (node['parent'], node['relation'], node['child'])) # Randomly place head

        return chunk

def process_random(video_id, sent_id, num_dependencies, dependency_tree, random_out):

    for i in range(0, 100):
        dep_total_random = 0
        random_dependencies =  list(iter_flatten(linearize_random(dependency_tree[0])))
        random_indices = {}
        for i in range (0, len(random_dependencies)):
            random_indices.update({random_dependencies[i][2].index: i + 1})
        for random_dep in random_dependencies:
            dep_total_random += get_dependency_length(random_dep, random_indices)
        random_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_random, num_dependencies))

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
        return abs(indices[governor.index] - indices[child.index])

def process_dependencies(video_id, doc, observed_out, optimal_out, random_out):
    sent_id = 0
    for sentence in doc.sentences:
        sent_id += 1

        true_dependencies = [dependency for dependency in sentence.dependencies if dependency[1] not in ["punct"]]
        num_dependencies = len(true_dependencies)

        if(num_dependencies < 1 or num_dependencies > 50):
            continue

        try:
            dependency_tree = tree(true_dependencies)
        except:
            print("Warning: tree construction failed for sentence {0}".format(sent_id))
            continue

        optimal_dependencies = list(iter_flatten(linearize_optimal(dependency_tree[0])))
        dependencies = list(zip(true_dependencies, optimal_dependencies))

        true_indices, optimal_indices, random_indices = ({}, {}, {})
        for i in range (0, len(dependencies)):
            true_indices.update({true_dependencies[i][2].index: i + 1})
            optimal_indices.update({optimal_dependencies[i][2].index: i + 1})

        dep_total_true, dep_total_optimal = (0, 0)

        for (true_dep, optimal_dep) in dependencies:
            dep_total_true += get_dependency_length(true_dep, true_indices)
            dep_total_optimal += get_dependency_length(optimal_dep, optimal_indices)

        process_random(video_id, sent_id, num_dependencies, dependency_tree, random_out)

        if(dep_total_optimal > dep_total_true):
            count_bad += 1

        observed_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_true, num_dependencies))
        optimal_out.write("{0}, {1}, {2}, {3}\n".format(video_id, sent_id, dep_total_optimal, num_dependencies))

def process_lines(f):
     for line in f:
         if not re.search("^[0-9]", line):
             line = line.replace("はじめ）", "")
             line = line.replace("たなっち）", "")
             line = line.replace("ト）", "")
             no_weird_punct = "。".join([str for str in re.split("[　！？!?.…]", line)])
             no_etc = "".join([str for str in re.split("[wｗ～、()（）【】《》「」\[\]\n]", no_weird_punct) if str != ""])
             if(no_etc):
                no_attr = re.split("[：:]", no_etc)
                if len(no_attr) > 1:
                    yield ("".join(no_attr[1:]))
                else:
                    yield no_etc

if __name__ == '__main__':
    main(argv[1])
