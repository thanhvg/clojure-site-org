import sys
import os
import subprocess

dir_list = ['about', 'guides', 'reference', 'api']

CWD_PATH = os.getcwd()


def make_org_file_from_adoc(source_file, docbook_file, org_file):
    print(source_file, docbook_file, org_file)
    os.makedirs(os.path.dirname(docbook_file), exist_ok=True)
    subprocess.run(['asciidoctor', '-b', 'docbook5',
                    source_file, '-o', docbook_file])
    subprocess.run(['pandoc', '-f', 'docbook',
                    docbook_file, '-o', org_file])

    os.remove(docbook_file)


def make_org_file_from_html(source_file, org_file):
    print(source_file, org_file)
    os.makedirs(os.path.dirname(org_file), exist_ok=True)
    subprocess.run(['pandoc', source_file, '-o', org_file])


def clean_cheatshet_file(filename):
    with open(filename, 'r') as source:
        lines = source.readlines()

    with open(filename, 'w') as source:
        keep = True
        for line in lines:
            if line == '\n': continue
            if line.startswith('#+BEGIN_HTML'):
                keep = False

            if keep:
                source.write(line)
            if line.startswith('#+END_HTML'):
                keep = True


if __name__ == '__main__':
    source_path = sys.argv[1] + '/content'
    source_path_absolute = os.path.abspath(source_path)
    cut_off_point = len(source_path_absolute) + 1
    source_dirs = [source_path + '/' + name for name in dir_list]
    source_adoc_files = []
    source_html_files = []

    # for dir in source_dirs:
    #     for a_file in os.listdir(dir):
    #         if a_file.endswith('.adoc'):
    #             source_adoc_files.append(a_file)
    # print(source_adoc_files)

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
                    source_adoc_files.append((
                        # absolute path
                        os.path.join(dirname, filename),
                        # relative like path
                        rel_path,
                        # base name without extension
                        os.path.splitext(filename)[0]
                    ))

                if filename.endswith('.html'):
                    source_html_files.append((
                        # absolute path
                        os.path.join(dirname, filename),
                        # relative like path
                        rel_path,
                        # base name without extension
                        os.path.splitext(filename)[0]
                    ))

    # print(source_adoc_files)

    for source_file, rel_path, basename in source_adoc_files:
        make_org_file_from_adoc(
            source_file,
            os.path.join(CWD_PATH, rel_path, basename + '.xml'),
            os.path.join(CWD_PATH, rel_path, basename + '.org')
        )

    for source_file, rel_path, basename in source_html_files:
        make_org_file_from_html(
            source_file,
            os.path.join(CWD_PATH, rel_path, basename + '.org')
        )

    clean_cheatshet_file(
            os.path.join(CWD_PATH, 'api', 'cheatsheet.org'))
