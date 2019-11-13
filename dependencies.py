import stanfordnlp, random, re
from sys import argv
from glob import glob
from os.path import exists, join
from os import makedirs, getcwd

def main(argv):
    sub_files = glob(join("subtitles", argv[0], "*.srt"))
    nlp = stanfordnlp.Pipeline(lang="ja")
    process_files(nlp, sub_files, argv[0])

def process_files(nlp, files, dir):
    if not exists(join("dependencies", dir)):
        makedirs(join("dependencies", dir))

    with open(join("dependencies", dir, "dependencies_out.csv"), "w") as outfile:
        outfile.write("video_id, sentence_id, dep_total_original, dep_total_random, total_words\n")
        vid_count = 0
        for f in files:
            vid_count += 1
            with open(f, "r") as subfile:
                print("Processing: {0}".format(f))
                processed_lines = list(process_lines(subfile))
                print(len(processed_lines))
                if len(processed_lines) != 0:
                    nlp_processed = nlp("。".join(processed_lines))
                    for dependency in dependencies(nlp_processed):
                        outfile.write("{0}, {1}, {2}, {3}, {4}\n".format(vid_count, dependency["sentence_id"], dependency["original_dep_l"], dependency["random_dep_l"],  dependency["total_words"]))
    print("Processed {0} files".format(len(files)))

def dependencies(doc):
    sent_count = 0
    for sentence in doc.sentences:
        sent_count =+ 1
        new_inds = [i for i in range (0, len(sentence.dependencies) + 1)]
        random.shuffle(new_inds)
        total_length, total_length_rand = (0, 0)
        for dependency in sentence.dependencies:
            if dependency[1] not in ["punct"]:
                dep_length = int(dependency[0].index) - int(dependency[2].index)
                dep_length_rand = new_inds[int(dependency[0].index)] - new_inds[int(dependency[2].index)]
                total_length += abs(dep_length)
                total_length_rand += abs(dep_length_rand)
        total_words = len(sentence.dependencies)
        yield ({"original_dep_l": total_length, "total_words": total_words, "random_dep_l": total_length_rand, "sentence_id": sent_count})

def process_lines(f):
     for line in f:
         if not re.search("^[0-9]", line):
             tmp = line.split("：")
             for utterance in tmp:
                 no_punct = re.split("[～。！？!?.()（）「」\[\]\n]", utterance)
                 for str in no_punct:
                     if str and len(str) >= 5 and len(str) < 50:
                         yield str

if __name__ == '__main__':
    main(argv[1:])
