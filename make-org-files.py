import sys
import os
import subprocess

dir_list = ['about', 'guides', 'reference']

CWD_PATH = os.getcwd()


def make_org_file(source_file, dest_file):
    os.makedirs(os.path.dirname(source_file), exist_ok=True)
    subprocess.run('asciidoctor', '-b', 'docbook',
                   source_file, '-o', dest_file)


if __name__ == '__main__':
    source_path = sys.argv[1]
    source_dirs = [source_path + '/' + name for name in dir_list]
    source_files = []
    for dir in source_dirs:
        for a_file in os.listdir(dir):
            if a_file.endswith('.adoc'):
                source_files.append(a_file)
    print(source_files)

    for dirname, dirnames, filenames in os.walk(source_path):
        # print path to all subdirectories first.
        for subdirname in dirnames:
            print(os.path.join(dirname, subdirname))

        # print path to all filenames.
        for filename in filenames:
            print(os.path.join(dirname, filename))
