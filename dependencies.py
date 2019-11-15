import stanfordnlp, random, re
from sys import argv
from glob import glob
from os.path import exists, join
from os import makedirs, getcwd

def main(argv):
    sub_files = glob(join("subtitles", argv[0], "*.srt"))
    nlp = stanfordnlp.Pipeline(lang="ja")
    process_files(nlp, sub_files, argv[0], int(argv[1]))

def process_files(nlp, files, channel, start):
    if not exists(join("dependencies", channel)):
        makedirs(join("dependencies", channel))

    with open(join("dependencies", channel, channel + "_dependencies.csv"), "w") as outfile:
        outfile.write("video_id, sentence_id, dep_total_true, dep_total_optimal, dep_total_random, num_dependencies\n")
        vid_count = 0
        for f in files:
            vid_count += 1
            if(vid_count < start):
                continue
            with open(f, "r") as subfile:
                print("Processing: {0}".format(f))
                processed_lines = list(process_lines(subfile))
                print("Found {0} lines".format(len(processed_lines)))
                if len(processed_lines) != 0:
                    nlp_processed = nlp("。".join(processed_lines))
                    for (sent_id, dep_total_true, dep_total_optimal, dep_total_random, num_dependencies) in dependencies(nlp_processed, vid_count):
                        outfile.write("{0}, {1}, {2}, {3}, {4}, {5}\n".format(vid_count, sent_id, dep_total_true, dep_total_optimal, dep_total_random, num_dependencies))
    print("Processed {0} files".format(len(files)))

def linearize_optimal(node):
    if not len(node['children']):
        return [(node['parent'], node['relation'], node['child'])]
    else:
        chunk = [(node['parent'], node['relation'], node['child'])]
        sorted_children = node['children']
        sorted_children.sort(key=weight)

        for i in range(0, len(sorted_children)):
            if i % 2:
                chunk.append(linearize_optimal(sorted_children[i]))
            else:
                chunk.insert(0, linearize_optimal(sorted_children[i]))
        return chunk

def linearize_random(node):

    if not len(node['children']):
        return [(node['parent'], node['relation'], node['child'])]

    else:
        chunk = []
        random_children = node['children']
        random.shuffle(random_children)

        for child in random_children:
            i = random.randint(0,2) # Coinflip
            if i:
                chunk.append(linearize_random(child))
            else:
                chunk.insert(0, linearize_random(child))

        i = random.randint(0, len(chunk))
        chunk.insert(i, (node['parent'], node['relation'], node['child']))

        return chunk

def weight(node):
    return len(node['children']) + sum(map(weight, node['children']))

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

def dependencies(doc, i):
    sent_id = 0
    for sentence in doc.sentences:
        sent_id += 1

        true_dependencies = [dependency for dependency in sentence.dependencies if dependency[1] != "punct"]
        num_dependencies = len(true_dependencies)

        if(num_dependencies < 1 or num_dependencies > 50):
            continue

        try:
            dependency_tree = tree(true_dependencies)
        except:
            print("Warning: tree construction failed for sentence {0}".format(sent_id))
            continue

        optimal_dependencies = list(iter_flatten(linearize_optimal(dependency_tree[0])))
        random_dependencies =  list(iter_flatten(linearize_random(dependency_tree[0])))
        dependencies = list(zip(true_dependencies, optimal_dependencies, random_dependencies))

        true_indices, optimal_indices, random_indices = ({}, {}, {})
        for i in range (0, len(dependencies)):
            true_indices.update({true_dependencies[i][2].index: i + 1})
            optimal_indices.update({optimal_dependencies[i][2].index: i + 1})
            random_indices.update({random_dependencies[i][2].index: i + 1})

        dep_total_true, dep_total_random, dep_total_optimal = (0, 0, 0)

        for (true_dep, optimal_dep, random_dep) in dependencies:
            dep_total_true += get_dependency_length(true_dep, true_indices)
            dep_total_optimal += get_dependency_length(optimal_dep, optimal_indices)
            dep_total_random += get_dependency_length(random_dep, random_indices)

        if(dep_total_true < dep_total_optimal):
            print("True: {0}, Optimal: {1}, Random: {2}, Total dependencies: {3}".format(dep_total_true, dep_total_optimal, dep_total_random, num_dependencies))

        yield (sent_id, dep_total_true, dep_total_optimal, dep_total_random, num_dependencies)

def process_lines(f):
     for line in f:
         if not re.search("^[0-9]", line):
             tmp = line.split("：")
             for utterance in tmp:
                 no_weird_punct = "。".join([str for str in re.split("[！？!?.]", utterance)])
                 no_etc = "".join([str for str in re.split("[～、()（）【】「」\[\]\n]", no_weird_punct) if str != ""])
                 if(no_etc):
                     yield no_etc

if __name__ == '__main__':
    main(argv[1:])
