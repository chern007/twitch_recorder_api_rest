from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({'message': 'Hello World'})

@app.route('/hello/<name>')
def hello(name):
    return jsonify({'message': f'Hello {name}'})