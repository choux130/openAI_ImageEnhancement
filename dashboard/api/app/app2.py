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
    bicubic_img = cv2.resize(img, None, fx = 8, fy = 8, interpolation = cv2.INTER_CUBIC)    
    cv2.imwrite(folder_path + '/' + 'hr_bicubic.jpg', bicubic_img)

    # Upscale the image
    Final_Img = sr.upsample(img)

    # Save the image
    cv2.imwrite(folder_path + '/' + 'hr.jpg', Final_Img)

    return jsonify({'msg': 'success',
                    'original_shape': img.shape,
                    'final_shape': Final_Img.shape})

# #### BasicSR ####
# import glob
# import numpy as np
# import os
# import torch

# import sys
# project_path = os.path.dirname(os.path.realpath(__file__))
# sys.path.append(project_path + '/BasicSR')
# from basicsr.archs.rrdbnet_arch import RRDBNet

# m_path = 'BasicSR/experiments/pretrained_models/ESRGAN/ESRGAN_SRx4_DF2KOST_official-ff704c30.pth'
# device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
# # set up model
# model = RRDBNet(
#     num_in_ch=3, num_out_ch=3, num_feat=64, num_block=23, num_grow_ch=32)
# model.load_state_dict(torch.load(m_path)['params'], strict=True)
# model.eval()
# model = model.to(device)

# @app.route("/sr_esrgan_x4", methods=["POST"])
# def super_resolution_esrgan():
#     # Get variables
#     file = request.files['image']
#     filename = request.headers['file_name']

#     # Make a directory
#     folder_path = 'output/' + 'esrgan_x4' + filename  
#     os.makedirs(folder_path, exist_ok=True)

#     # Read the image via file.stream
#     img = Image.open(file.stream)

#     # Convert to cv2 object and save the original image
#     img = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
#     cv2.imwrite(folder_path + '/' + 'lr.jpg', img)

#     # Inference
#     for idx, path in enumerate(
#             sorted(glob.glob(os.path.join(folder_path, '*')))):
#         imgname = os.path.splitext(os.path.basename(path))[0]
#         print('Testing', idx, imgname)
#         # Read image
#         img = cv2.imread(path, cv2.IMREAD_COLOR).astype(np.float32) / 255.
#         img = torch.from_numpy(np.transpose(img[:, :, [2, 1, 0]],
#                                             (2, 0, 1))).float()
#         img = img.unsqueeze(0).to(device)
#         # Inference
#         with torch.no_grad():
#             output = model(img)
#         # Save image
#         output = output.data.squeeze().float().cpu().clamp_(0, 1).numpy()
#         output = np.transpose(output[[2, 1, 0], :, :], (1, 2, 0))
#         output = (output * 255.0).round().astype(np.uint8)
#         cv2.imwrite(folder_path + '/' + 'hr.jpg', output)

#     # Bicubic resize and save the image
#     bicubic_img = cv2.resize(img, None, fx = 4, fy = 4, interpolation = cv2.INTER_CUBIC)    
#     cv2.imwrite(folder_path + '/' + 'hr_bicubic.jpg', bicubic_img)

#     return jsonify({'msg': 'success',
#                     'original_shape': img.shape,
#                     'final_shape': output.shape})

if __name__ == "__main__":
    app.run(debug=True, host= '0.0.0.0', port=8050)

