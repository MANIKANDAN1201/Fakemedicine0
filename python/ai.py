# app.py
from flask import Flask, request, jsonify
import google.generativeai as genai

app = Flask(__name__)

genai.configure(api_key='AIzaSyAprunPJ7iQ_nFtBK8wTd9L2S0qRXkzh_8')
generation_config = {
    "temperature": 0.9,
    "top_p": 1,
    "top_k": 1,
    "max_output_tokens": 2048,
}
model = genai.GenerativeModel(model_name="models/gemini-1.5-pro",
                             generation_config=generation_config)
convo = model.start_chat(history=[])

def to_markdown(text):
    text = text.replace('•', '  *')
    return '\n'.join([f'> {line}' for line in text.split('\n')])

@app.route('/ask-gemini', methods=['POST'])
def ask_gemini():
    data = request.json
    query = data.get('query', '')

    prompt = f"Write a prescription in pointer format ordered by name of medicine, symptoms, primary diagnosis, usage and dosage of medicine in the image."
    response = convo.send_message(prompt)

    markdown_text = to_markdown(response)
    return jsonify({'response': markdown_text})

if __name__ == '__main__':
    app.run(debug=True)
