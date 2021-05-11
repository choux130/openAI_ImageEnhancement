import requests

def run_api(url, file_path, file_name):
  
  my_img = {'image': open(file_path, 'rb')}
  header = {'file_name': file_name}
  r = requests.post(url, files=my_img, headers = header, timeout=1000)

  return(r.status_code)


