import fileinput
import shutil
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("PACKAGENAME")
parser.add_argument("PACKAGEVERSION")
parser.add_argument("REPOSITORYID")
parser.add_argument("PACKAGEURL")

args = parser.parse_args()


shutil.copyfile("new_package.json.template", "new_package.json")

for line in fileinput.FileInput("new_package.json", inplace=True):
    line = line.replace("PACKAGENAME",args.PACKAGENAME)
    line = line.replace("PACKAGEVERSION",args.PACKAGEVERSION)
    line = line.replace("REPOSITORYID",args.REPOSITORYID)
    line = line.replace("PACKAGEURL",args.PACKAGEURL)



    print line



