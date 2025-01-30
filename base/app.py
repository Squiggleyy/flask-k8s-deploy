from flask import Flask, render_template, jsonify
import random
import requests

# Import OpenTelemetry libraries:
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
import logging

# Set up logging to debug OpenTelemetry
logging.basicConfig(level=logging.DEBUG)

# ✅ Step 1: Set up Tracer Provider
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# ✅ Step 2: Set up OTLP Exporter to send traces to Observe Agent (OTel Collector)
otlp_exporter = OTLPSpanExporter(endpoint="http://observe-agent-node-logs-metrics.observe.svc.cluster.local:4317")

# ✅ Step 3: Add the Span Processor
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))

# ✅ Step 4: Initialize Flask App
app = Flask(__name__)

# ✅ Step 5: Instrument Flask for OpenTelemetry
FlaskInstrumentor().instrument_app(app)

@app.route('/')
def home():
    with tracer.start_as_current_span("home-span"): # Example span instrumentation
        return render_template('main.html')

@app.route('/about')
def about():
    return "This is the About page."

@app.route('/greet/<name>')
def greet(name):
    return f"Hello, {name.capitalize()}! Welcome to our Flask app!"

@app.route('/random/<int:start>/<int:end>')
def random_number(start, end):
    number = random.randint(start, end)
    return f"Your random number between {start} and {end} is: {number}"

@app.route('/joke')
def joke():
    jokes = [
        "Why don’t skeletons fight each other? They don’t have the guts.",
        "What do you call fake spaghetti? An impasta!",
        "How does a penguin build its house? Igloos it together."
    ]
    return random.choice(jokes)

@app.route('/funfact')
def funfact():
    facts = [
        "Honey never spoils.",
        "Octopuses have three hearts.",
        "Bananas are berries, but strawberries aren’t."
    ]
    return random.choice(facts)

@app.route('/fetch_joke')
def fetch_joke():
    # URL of the external REST API
    api_url = "https://official-joke-api.appspot.com/random_joke"

    try:
        # Make a GET request to the API
        response = requests.get(api_url)

        # Check if the response is successful
        if response.status_code == 200:
            joke_data = response.json()
            return jsonify({
                "setup": joke_data["setup"],
                "punchline": joke_data["punchline"]
            })
        else:
            return jsonify({"error": "Failed to fetch joke"}), response.status_code

    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)