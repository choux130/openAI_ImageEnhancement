from flask import Flask, request, jsonify
import pdb
app = Flask(__name__)

#### Super Resolution - openCV ####
from PIL import Image
import cv2
import numpy as np
import os
import time
from cv2 import dnn_superres

# Create an SR object
sr = dnn_superres.DnnSuperResImpl_create()
m_name = "LapSRN_x8.pb"
print(m_name)
# Define model path
model_path = "SuperResolution_opencv/models/" + m_name
# Extract model name 
model_name =  model_path.split('/')[2].split('_')[0].lower()
# Extract model scale
model_scale = int(model_path.split('/')[2].split('_')[1].split('.')[0][1])
# Read the desired model
sr.readModel(model_path)
# Set the desired model and scale to get correct pre-processing and post-processing
sr.setModel(model_name, model_scale)

@app.route('/healthcheck', methods=['GET'])
def gethealthcheck():
  return('success')

@app.route("/sr_lapsrn_x8", methods=["POST"])
def super_resolution_lapsrn():
    # Get variables
    file = request.files['image']
    filename = request.headers['file_name']

    # Make a directory
    folder_path = 'output/' + 'lapsrn_x8_' + filename  
    os.makedirs(folder_path, exist_ok=True)

    # Read the image via file.stream
    img = Image.open(file.stream)

    # Convert to cv2 object and save the original image
    img = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
    cv2.imwrite(folder_path + '/' + 'lr.jpg', img)

    # Bicubic resize and save the image
    # bicubic_img = cv2.resize(img, None, fx = 8, fy = 8, interpolation = cv2.INTER_CUBIC)    
    # cv2.imwrite(folder_path + '/' + 'hr_bicubic.jpg', bicubic_img)

    # Upscale the image
    Final_Img = sr.upsample(img)

    # Save the image
    cv2.imwrite(folder_path + '/' + 'hr.jpg', Final_Img)

    return jsonify({'msg': 'success',
                    'original_shape': img.shape,
                    'final_shape': Final_Img.shape})

if __name__ == "__main__":
    app.run(debug=True, host= '0.0.0.0', port=8050)
