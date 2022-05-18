import threading
import time

from carla import Client, VehicleControl, command

from dora_tracing import extract_context, tracer
from dora_watermark import dump, load

CARLA_SIMULATOR_HOST = "localhost"
CARLA_SIMULATOR_PORT = "2000"
client = Client(CARLA_SIMULATOR_HOST, int(CARLA_SIMULATOR_PORT))
client.set_timeout(30.0)
vehicle_id = None

mutex = threading.Lock()

def run(inputs):
    global vehicle_id

    if vehicle_id is None and "vehicle_id" not in inputs.keys():
        return {}
    elif vehicle_id is None and "vehicle_id" in inputs.keys():
        global mutex
        mutex.acquire()
        vehicle_id = load(inputs, "vehicle_id")
        mutex.release()

    if "control" not in inputs.keys():
        return {}

    control = load(inputs, "control")

    vec_control = VehicleControl(
        throttle=control["throttle"],
        steer=control["steer"],
        brake=control["brake"],
        hand_brake=False,
        reverse=False,
    )

    context = extract_context(inputs)

    with tracer.start_span(f"within-python-{__name__}", context=context) as span:
        client.apply_batch_sync(
            [command.ApplyVehicleControl(vehicle_id, vec_control)]
        )
        return {"control_status": dump(1)}
