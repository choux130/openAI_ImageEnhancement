import requests

url = 'http://127.0.0.1:8050/sr_lapsrn_x8'
# url = 'http://127.0.0.1:8050/sr_esrgan_x4'

my_img = {'image': open('../ui/app/example_img/ca.png', 'rb')}
header = {'file_name': "ca.png"}
r = requests.post(url, files=my_img, headers = header)

# convert server reaponse into JSON format.
print(r.json())


from os import listdir

url = 'http://127.0.0.1:8050/sr_lapsrn_x8'
files = listdir("../ui/app/example_img")
files = list(filter(lambda x: x!='.DS_Store', files))

for i in range(0, len(files)):
    print(i)
    file_name = files[i]
    print(file_name)
    my_img = {'image': open("../ui/app/example_img/" + file_name, 'rb')}
    header = {'file_name': file_name}
    r = requests.post(url, files=my_img, headers = header)



