from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Bienvenue sur StreamBox !", "env": "Dev"}), 200

@app.route('/movies')
def movies():
    data = [
        {"id": 1, "title": "Inception", "rating": 8.8},
        {"id": 2, "title": "Interstellar", "rating": 8.6}
    ]
    return jsonify(data), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)