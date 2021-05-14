from flask import Flask, request, jsonify
import pdb
app = Flask(__name__)

#### ISR - RRDN GANS ####
import os
from ISR.models import RDN, RRDN
import numpy as np
from PIL import Image

rrdn_gans = RRDN(arch_params={'C': 4, 'D':3, 'G':32, 'G0':32, 'x':4, 'T': 10})
rrdn_gans = RRDN(arch_params={'C': 4, 'D':3, 'G':32, 'G0':32, 'x':4, 'T': 10})
rrdn_gans.model.load_weights('ISR/rrdn-C4-D3-G32-G032-T10-x4_epoch299.hdf5')

@app.route("/sr_lapsrn_x8", methods=["POST"])
def super_resolution_esrgan():
    # pdb.set_trace()
    # Get variables
    file = request.files['image']
    filename = request.headers['file_name']

    # Make a directory
    folder_path = 'output/' + 'lapsrn_x8_' + filename  
    os.makedirs(folder_path, exist_ok=True)

    # Read the image via file.stream
    img = Image.open(file.stream)
    array = np.array(img)
    if array.shape[2] == 4:
        # rgba           
        img.load()
        img2 = Image.new("RGB", img.size, (255, 255, 255))
        img2.paste(img, mask=img.split()[3]) # 3 is the alpha channel
    else: 
        img2 = img
    # img2.save(folder_path + '/' + 'lr.jpg')

    # pdb.set_trace()
    # Inference
    array = np.array(img2)
    sr_img = rrdn_gans.predict(array)
    
    # pdb.set_trace()
    result_img = Image.fromarray(sr_img)
    result_img.save(folder_path + '/' + 'hr.jpg')

    return jsonify({'msg': 'success',
                    'original_shape': img.size,
                    'final_shape': result_img.size})

if __name__ == "__main__":
    app.run(debug=True, host= '0.0.0.0', port=8050)

