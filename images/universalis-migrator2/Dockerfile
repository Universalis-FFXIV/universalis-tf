FROM python:3.10.8
COPY requirements.txt requirements.txt
RUN python3 -m pip install -r requirements.txt
COPY . .
CMD [ "python3", "migrator.py" ]