import compileall
import zipfile
import os

compileall.compile_dir('Lib',force=True,legacy=True,optimize=2)

from Lib.lib2to3.pgen2.driver import main as grammar_gen

grammar_gen('Lib/lib2to3/Grammar.txt','Lib/lib2to3/PatternGrammar.txt')

missed_dir = [
'__pycache__','test','ensurepip','idlelib','venv','tests','turtledemo','pydoc-data','site-packages'
]
missed_file = [
'turtle.pyc'
]

def allow_ext(fname):
  _, ext = os.path.splitext(fname)
  return ext in ('.pyc','.pickle','.pem')

zf = zipfile.ZipFile("python37.zip", "w", zipfile.ZIP_DEFLATED, True, 9)

os.chdir("Lib")

for dirname, subdirs, files in os.walk('.'):
    for p in dirname.split(os.path.sep):
        if p in missed_dir:
            break
    else:
         dirname = dirname[2:]
         print(dirname)
         not_saved = bool(dirname)
         for filename in files:
             if allow_ext(filename) and filename not in missed_file:
                 if not_saved:
                     not_saved = False
                     zf.write(dirname)
                 zf.write(os.path.join(dirname, filename))

os.chdir("..")

zf.close()
