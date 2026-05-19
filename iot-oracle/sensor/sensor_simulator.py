"""
AeroTrack IoT Sensor Simulator
Simulates an airplane part sensor publishing data to MQTT broker.
This represents a physical sensor (temperature, vibration) on a turbine blade.
"""

import paho.mqtt.client as mqtt
import json
import time
import random

# --- Configuration ---
MQTT_BROKER = "localhost"
MQTT_PORT = 1883
MQTT_TOPIC = "aerotrack/sensors/part999"

# Sensor identity
SENSOR_ID = "SENSOR-TEMP-001"
PART_SERIAL = 999
SENSOR_TYPE = "temperature"


def generate_reading():
    """Simulate a temperature reading from a turbine blade sensor."""
    # Normal operating range: 70-90°C
    # Occasionally spike to simulate stress
    base_temp = random.uniform(70.0, 90.0)
    
    # 10% chance of a warning-level reading
    if random.random() < 0.1:
        base_temp = random.uniform(95.0, 110.0)
    
    return {
        "sensorId": SENSOR_ID,
        "partSerial": PART_SERIAL,
        "sensorType": SENSOR_TYPE,
        "dataType": "temperature",
        "value": f"{base_temp:.1f}C",
        "status": "WARNING" if base_temp > 95 else "NORMAL",
        "timestamp": int(time.time())
    }


def on_connect(client, userdata, flags, reason_code, properties):
    """Callback when connected to MQTT broker."""
    print(f"[SENSOR] Connected to MQTT broker (code: {reason_code})")
    print(f"[SENSOR] Publishing to topic: {MQTT_TOPIC}")
    print(f"[SENSOR] Sensor ID: {SENSOR_ID} | Part: {PART_SERIAL}")
    print("-" * 50)


def main():
    print("=" * 50)
    print("  AeroTrack IoT Sensor Simulator")
    print("  Turbine Blade Temperature Sensor")
    print("=" * 50)
    print()

    # Connect to MQTT broker
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect

    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_start()
    except ConnectionRefusedError:
        print("[ERROR] Cannot connect to MQTT broker!")
        print("[ERROR] Make sure Mosquitto is running: docker-compose up -d")
        return

    time.sleep(1)  # Wait for connection

    print("[SENSOR] Starting readings (every 5 seconds)...")
    print("[SENSOR] Press Ctrl+C to stop")
    print()

    try:
        reading_count = 0
        while True:
            reading = generate_reading()
            payload = json.dumps(reading)

            # Publish to MQTT
            client.publish(MQTT_TOPIC, payload)
            reading_count += 1

            status_icon = "⚠️" if reading["status"] == "WARNING" else "✅"
            print(f"  [{reading_count}] {status_icon} {reading['value']} "
                  f"({reading['status']}) -> {MQTT_TOPIC}")

            time.sleep(5)  # Send reading every 5 seconds

    except KeyboardInterrupt:
        print(f"\n[SENSOR] Stopped after {reading_count} readings.")
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
