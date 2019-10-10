import sys
import os
import subprocess

dir_list = ['about', 'guides', 'reference']

CWD_PATH = os.getcwd()


def make_org_file(source_file, docbook_file, org_file):
    print(source_file, docbook_file, org_file)
    os.makedirs(os.path.dirname(docbook_file), exist_ok=True)
    subprocess.run(['asciidoctor', '-b', 'docbook',
                    source_file, '-o', docbook_file])
    subprocess.run(['pandoc', '-f', 'docbook',
                    docbook_file, '-o', org_file])

    # subprocess.run(['pandoc', '-h'])
    os.remove(docbook_file)


if __name__ == '__main__':
    source_path = sys.argv[1] + '/content'
    source_path_absolute = os.path.abspath(source_path)
    cut_off_point = len(source_path_absolute) + 1
    source_dirs = [source_path + '/' + name for name in dir_list]
    source_files = []

    # for dir in source_dirs:
    #     for a_file in os.listdir(dir):
    #         if a_file.endswith('.adoc'):
    #             source_files.append(a_file)
    # print(source_files)

    # the pain of FP lacking in python
    for source_dir in source_dirs:
        for dirname, dirnames, filenames in os.walk(source_dir):
            # print path to all subdirectories first.
            # for subdirname in dirnames:
            #     print(os.path.join(dirname, subdirname))

            rel_path = os.path.abspath(dirname)[cut_off_point:]
            for filename in filenames:
                if filename.endswith('.adoc'):
                    # print(os.path.join(dirname, filename))
                    source_files.append((
                        # absolute path
                        os.path.join(dirname, filename),
                        # relative like path
                        rel_path,
                        # base name without extension
                        os.path.splitext(filename)[0]
                    ))

    # print(source_files)

    for source_file, rel_path, basename in source_files:
        make_org_file(
            source_file,
            os.path.join(CWD_PATH, rel_path, basename + '.xml'),
            os.path.join(CWD_PATH, rel_path, basename + '.org')
        )
