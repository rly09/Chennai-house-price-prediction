from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import pickle
import os

app = Flask(__name__)
CORS(app)

# Load Model and Data
# Assuming files are in the parent directory as observed in file listing
MODEL_PATH = os.path.join(os.path.dirname(__file__), '../RidgeModel.pkl')
DATA_PATH = os.path.join(os.path.dirname(__file__), '../Cleaned_data.csv')

try:
    model = pickle.load(open(MODEL_PATH, 'rb'))
    data = pd.read_csv(DATA_PATH)
    print("Model and Data Loaded Successfully")
except Exception as e:
    print(f"Error loading model or data: {e}")
    model = None
    data = None

@app.route('/locations', methods=['GET'])
def get_locations():
    if data is not None:
        locations = sorted(data['location'].unique().tolist())
        return jsonify({'locations': locations})
    return jsonify({'error': 'Data not loaded'}), 500

@app.route('/predict', methods=['POST'])
def predict():
    if model is None:
        return jsonify({'error': 'Model not loaded'}), 500
    
    req_data = request.get_json()
    location = req_data.get('location')
    bhk = float(req_data.get('bhk'))
    bathroom = float(req_data.get('bathroom'))
    area = float(req_data.get('area'))
    status = req_data.get('status') 

    print(f"Prediction Request: {req_data}")

    input_data = pd.DataFrame([[location, status, bhk, bathroom, area]], 
                              columns=['location', 'status', 'bhk', 'bathroom', 'area'])
    
    try:
        prediction = model.predict(input_data)[0]
        # Ensure price is not negative
        if prediction < 0:
            prediction = 0
            
        return jsonify({'price': prediction})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
