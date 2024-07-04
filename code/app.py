from flask import Flask
from flask_cors import CORS, cross_origin

from readFixedFile import processFixFile
from readfile import process
from readfileNew import processNewFull

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'
@app.route('/')
def hello(): return 'hello'


@app.route('/ciao', methods=['GET'])
@cross_origin()
def process():
    return process()


@app.route('/proc', methods=['GET'])
@cross_origin()
def process_full():
    return processNewFull()


@app.route('/procFix', methods=['GET'])
@cross_origin()
def process_fix_file_route():
    return processFixFile()


if __name__ == '__main__':
    app.run(host='0.0.0.0')
