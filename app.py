from transformers import AutoProcessor, AutoModelForCausalLM
from PIL import Image
import torch
from flask import Flask, request, jsonify
import soundfile as sf
from transformers import pipeline
import io

# Define model ID
model_id = 'microsoft/Florence-2-base'

# Check if CUDA (GPU) is available, otherwise use CPU
device = 'cuda' if torch.cuda.is_available() else 'cpu'

# Load the model and processor
model = AutoModelForCausalLM.from_pretrained(
    model_id, 
    trust_remote_code=True, 
    torch_dtype='auto'
).eval().to(device)  # Use 'cuda' if GPU is available, otherwise use CPU

processor = AutoProcessor.from_pretrained(model_id, trust_remote_code=True)

# Set up Flask app
app = Flask(__name__)

# Text-to-speech pipeline initialization
synthesiser = pipeline("text-to-speech", model="microsoft/speecht5_tts")
embeddings_dataset = load_dataset("Matthijs/cmu-arctic-xvectors", split="validation")
speaker_embedding = torch.tensor(embeddings_dataset[7306]["xvector"]).unsqueeze(0)

def generate_description(image_path, task_prompt, text_input=None):
    """
    Generate a description for the given image.
    """
    image = Image.open(image_path)
    image = image.convert('RGB')

    prompt = task_prompt if text_input is None else task_prompt + text_input

    inputs = processor(text=prompt, images=image, return_tensors="pt").to(device, torch.float16)

    generated_ids = model.generate(
        input_ids=inputs["input_ids"].cuda() if device == 'cuda' else inputs["input_ids"].cpu(),
        pixel_values=inputs["pixel_values"].cuda() if device == 'cuda' else inputs["pixel_values"].cpu(),
        max_new_tokens=1024,
        early_stopping=False,
        do_sample=False,
        num_beams=3,
    )

    generated_text = processor.batch_decode(generated_ids, skip_special_tokens=False)[0]
    parsed_answer = processor.post_process_generation(
        generated_text,
        task=task_prompt,
        image_size=(image.width, image.height)
    )

    return parsed_answer

def tts(text, out):
    """
    Convert text to speech and save the audio file.
    """
    speech = synthesiser(text, forward_params={"speaker_embeddings": speaker_embedding})
    sf.write(out, speech["audio"], samplerate=speech["sampling_rate"])

@app.route('/generate_description', methods=['POST'])
def generate_description_api():
    """
    API endpoint to receive an image and return the description and audio.
    """
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    image = request.files['image']
    image_path = 'temp_image.jpg'  # Temporary path for the uploaded image
    image.save(image_path)

    task_prompt = '<DETAILED_CAPTION>'
    description = generate_description(image_path, task_prompt)

    # Generate speech from the description
    audio_file = 'scene_description.wav'
    tts(description, audio_file)

    # Return the description as JSON response
    return jsonify({"description": description, "audio_file": audio_file})

if __name__ == "__main__":
    app.run(debug=True)
