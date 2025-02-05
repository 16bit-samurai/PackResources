# All files should be put in the /models_to_add directory
# The .json and .png file of one model should be named the same
# Run this script with -i <newpackname>

import csv, sys, getopt, json, os, shutil

#read args
abs_path = os.path.abspath('.')
pack_name = ''
import_dir = abs_path + '/models_to_add'
json_file_loc = abs_path + '/assets/minecraft/models/item/nw'
png_file_loc = abs_path + '/assets/minecraft/textures/nw'
old_cmd_loc = abs_path + '/assets/minecraft/models/item/firework_star.json'
new_cmd_loc = abs_path + 'overlay_1_21_4/assets/minecraft/items/firework_star.json'

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

json_file_list = []
png_file_list = []
for file_name in os.listdir(import_dir):
    if file_name.endswith('.json'):
        json_file_list.append(file_name)
    elif file_name.endswith('.png'):
        png_file_list.append(file_name)

json_file_count = len(json_file_list)
png_file_count = len(png_file_list)

print('Found ', json_file_count, ' JSON files and ', png_file_count, ' PNG files')

old_cmd_file = open(old_cmd_loc)
new_cmd_file = open(new_cmd_loc)

old_cmd_json = json.load(old_cmd_file)
new_cmd_json = json.load(new_cmd_file)

max_cmd = old_cmd_json['overrides'][-1]['predicate']['custom_model_data']

current_cmd = max_cmd - max_cmd % 1000 + 1000

for file_name in json_file_list:
    with open(import_dir + '/' + file_name) as file:
        jsondata = json.load(file)
        for key in jsondata['textures']:
            png_dir = jsondata['textures'][key]
            new_png_dir = 'nw/' + pack_name + '/' + str.split(png_dir,'/')[-1]
            jsondata['textures'][key] = new_png_dir
        file.write(json.dumps(jsondata))
    shutil.copy2(import_dir + '/' + file_name, json_file_loc + '/' + pack_name + '/' + file_name)
    
    model_name = 'item/nw/' + pack_name + '/' + str.rstrip(file_name,'.json')
    list.append(old_cmd_json['overrides'],{"predicate":{"custom_model_data":current_cmd},"model": model_name})
    list.append(new_cmd_json['model']['entries'],{"threshold": current_cmd,"model": {"type": "model","model": model_name,"tints": [{ "type": "constant", "value": -1 },{ "type": "firework", "default": -7697782 }]}})


old_cmd_file.write(json.dumps(old_cmd_json))
new_cmd_file.write(json.dumps(new_cmd_json))

old_cmd_file.close()
new_cmd_file.close()

for file_name in png_file_list:
    shutil.copy2(import_dir + '/' + file_name, png_file_loc + '/' + pack_name + '/' + file_name)

print('Successfully added new pack \"', pack_name, '\"')