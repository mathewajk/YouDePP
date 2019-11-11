import stanfordnlp
import sys.argv
import re
from glob import glob
from os.path import exists, join
from os import makedirs, getcwd

def main(argv):
    sub_files = glob(join("subtitles", argv[0], "*.srt"))
    nlp = stanfordnlp.Pipeline(lang="ja")
    process_files(sub_files)

def process_files(files):
    with open(join("dependencies", argv[0], "dependencies_out.csv"), "w") as outfile:
        outfile.write("total_dep_len, sent_len")
        for f in files:
            with open(f, "r") as subfile:
                print("Processing: {0}".format(f))
                processed_lines = list(process_lines(subfile))
                print(len(processed_lines))
                nlp_processed = nlp("。".join(processed_lines))
                for dependency in dependencies(nlp_processed):
                    outfile.write(str(dependency[0]) + ", " + str(dependency[1]) + "\n")
    print("Processed {0} files".format(len(sub_files)))

def dependencies(doc):
    for sentence in doc.sentences:
        count = 0
        total_length = 0
        for dependency in sentence.dependencies:
            count += 1
            if dependency[1] not in ["punct"]:
                dep_length = int(dependency[0].index) - int(dependency[2].index)
                total_length += abs(dep_length)
        yield (total_length, len(sentence.dependencies))

def process_lines(f):
     for line in f:
         if not re.search("^[0-9]", line):
             tmp = line.split("：")
             for utterance in tmp:
                 no_punct = re.split("[～。！？()（）「」\[\]\n]", utterance)
                 for str in no_punct:
                     if str and len(str) >= 10:
                         yield str

if __name__ == '__main__':
    main(sys.argv[1:])
