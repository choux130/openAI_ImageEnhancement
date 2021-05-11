import requests

url = 'http://127.0.0.1:8050/sr_lapsrn_x8'
url = 'http://127.0.0.1:8050/sr_esrgan_x4'
my_img = {'image': open('app/example_img/baby.png', 'rb')}
header = {'file_name': "baby.png"}
r = requests.post(url, files=my_img, headers = header)

# convert server reaponse into JSON format.
print(r.json())