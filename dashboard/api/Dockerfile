FROM python:3.6.10

RUN apt-get update 
RUN apt-get install ffmpeg libsm6 libxext6  -y

ADD . /api

RUN pip install -r api/requirements.txt
RUN pip -q install ISR gdown
RUN pip install --upgrade opencv-contrib-python
RUN pip install --upgrade opencv-python

EXPOSE 8050
WORKDIR /api/app
RUN mkdir -p ./output
ENTRYPOINT ["python", "app_ISR.py"]