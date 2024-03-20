from flask import Flask

from readfile import process

from flask_cors import CORS, cross_origin

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'
@app.route('/')
def hello(): return 'hello'


@app.route('/ciao', methods=['GET'])
@cross_origin()
def hello2():
    return process()


if __name__ == '__main__':
    app.run(debug=True)
