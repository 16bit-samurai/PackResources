# All files should be put in the /models_to_add/ directory
# Run this script with -i <new_pack_name>

import csv, sys, getopt, json, os, shutil

#read args
abs_path = os.path.abspath('.')
pack_name = ''

try:
    opts, args = getopt.getopt(sys.argv[1:],"h:i:o:",["help=","ifile="])
except getopt.GetoptError:
    print ('Usage: import-data.py -i <new_pack_name>')
    sys.exit()
for opt, arg in opts:
    if opt == '-h':
         print ('Usage: import-data.py -i <new_pack_name>')
         sys.exit()
    elif opt in ("-i", "--ifile"):
         pack_name = arg
if pack_name == '':
    print ('Usage: import-data.py -i <new_pack_name>')
    sys.exit()

#init dirs
import_dir = abs_path + '/models_to_add'
json_file_loc = abs_path + '/assets/minecraft/models/item/nw/' + pack_name + '/'
png_file_loc = abs_path + '/assets/minecraft/textures/nw/' + pack_name + '/'
old_cmd_loc = abs_path + '/assets/minecraft/models/item/firework_star.json'
new_cmd_loc = abs_path + '/overlay_1_21_4/assets/minecraft/items/firework_star.json'
csv_file = abs_path + '/new_pack_cmd.csv'

try:
    os.mkdir(json_file_loc)
except FileExistsError: 
    print('Pack name duplicated, ignoring..')

try:
    os.mkdir(png_file_loc)
except FileExistsError: 
    pass

#find all files
json_file_list = []
png_file_list = []
for file_name in os.listdir(import_dir):
    if file_name.endswith('.json'):
        json_file_list.append(file_name)
    elif file_name.endswith('.png'):
        png_file_list.append(file_name)
    elif file_name.endswith('.png.mcmeta'):
        png_file_list.append(file_name)

json_file_count = len(json_file_list)
png_file_count = len(png_file_list)

print('Found', json_file_count, 'JSON files and', png_file_count, 'PNG files')

#read cmd file
old_cmd_file = open(old_cmd_loc, 'r+')
new_cmd_file = open(new_cmd_loc, 'r+')

old_cmd_json = json.load(old_cmd_file)
new_cmd_json = json.load(new_cmd_file)

max_cmd = old_cmd_json['overrides'][-1]['predicate']['custom_model_data']

current_cmd = max_cmd - max_cmd % 1000 + 1000

#init csv data
cmd_rows = []

#copy & modify json files
for file_name in json_file_list:
    with open(import_dir + '/' + file_name, 'r+') as file:
        jsondata = json.load(file)
        for key in jsondata['textures']:
            png_dir = jsondata['textures'][key]
            new_png_dir = 'nw/' + pack_name + '/' + str.split(png_dir,'/')[-1]
            jsondata['textures'][key] = new_png_dir
        file.seek(0)
        file.write(json.dumps(jsondata,indent=2))
        file.truncate()
    shutil.copy2(import_dir + '/' + file_name, json_file_loc)
    
    #add cmd
    model_name = 'item/nw/' + pack_name + '/' + str.rstrip(file_name,'.json')
    list.append(old_cmd_json['overrides'],{"predicate":{"custom_model_data":current_cmd},"model": model_name})
    list.append(new_cmd_json['model']['entries'],{"threshold": current_cmd,"model": {"type": "model","model": model_name,"tints": [{ "type": "constant", "value": -1 },{ "type": "firework", "default": -7697782 }]}})
    list.append(cmd_rows, [pack_name + '/' + str.rstrip(file_name,'.json'),current_cmd])
    current_cmd += 1

#save cmd files
old_cmd_file.seek(0)
old_cmd_file.write(json.dumps(old_cmd_json,indent=2))
old_cmd_file.truncate()

new_cmd_file.seek(0)
new_cmd_file.write(json.dumps(new_cmd_json,indent=2))
new_cmd_file.truncate()

old_cmd_file.close()
new_cmd_file.close()

#save csv file
with open(csv_file, 'w') as file:
    writer = csv.writer(file)
    writer.writerows(cmd_rows)

#copy png files
for file_name in png_file_list:
    shutil.copy2(import_dir + '/' + file_name, png_file_loc)

#finish
print('Successfully added new pack', pack_name)