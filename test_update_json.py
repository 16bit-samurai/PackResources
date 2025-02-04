# Run this script with -i <filename>

import csv, sys, getopt, json, os

#read args
abs_path = os.path.abspath('.')
f_path = ''
o_path = ''
try:
    opts, args = getopt.getopt(sys.argv[1:],"h:i:o:",["help=","ifile=","ofile="])
except getopt.GetoptError:
    print ('Usage: import-data.py -i <f_path> [-o <f_path>]')
    sys.exit()
for opt, arg in opts:
    if opt == '-h':
         print ('Usage: import-data.py -i <f_path> [-o <f_path>]')
         sys.exit()
    elif opt in ("-i", "--ifile"):
         f_path = arg
    elif opt in ("-o", "--ofile"):
         o_path = arg
if f_path == '':
    print ('Usage: import-data.py -i <f_path>')
    sys.exit()
if o_path == '':
    o_path = 'output'

try:
    os.mkdir(abs_path + '/' + o_path + '/')
except FileExistsError: 
    print('directory alreay exists')

print('Reading from ', f_path)

#read file
rows = []
with open(f_path) as file:
    jsondata = json.load(file)

for entry in jsondata['model']['entries']:
    entry['model']['tints'] = [ { "type": "constant", "value": -1 }, { "type": "firework", "default": -7697782 } ]

#output file
outfile = open(abs_path + '/' + o_path + '/output.json', 'w')
outfile.write(json.dumps(jsondata))
outfile.close()

print('files generated at', o_path)