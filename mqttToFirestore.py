import json 
import paho.mqtt.client as mqtt
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore import SERVER_TIMESTAMP

# initialzie firestore
cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)
db = firestore.client()

# mqtt settings
mqttBroker = "localhost"
mqttTopic = "iot/compost"
mqttPort = 1883

def on_message(client, userdata, msg):
        data = json.loads(msg.payload.decode())

        print("Received:", data)

        # write into firestore
        db.collection("compostSensorData").add({
  	"deviceID": data["deviceID"],
        "timestamp": SERVER_TIMESTAMP,
        "airTemperature": data["airTemperature"],
        "soilTemperature": data["soilTemperature"],
        "soilMoisture": data["soilMoisture"],
        "IRDistanceRaw": data["IRDistanceRaw"]
        })

client = mqtt.Client()
client.connect(mqttBroker, 1883)
client.subscribe(mqttTopic)
client.on_message = on_message

print("MQTT to Firestore connection running ...")
client.loop_forever()

