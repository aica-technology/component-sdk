from modulo_components.lifecycle_component import LifecycleComponent
import state_representation as sr

class PyLifecycleComponent(LifecycleComponent):
    def __init__(self, node_name: str, *args, **kwargs):
        super().__init__(node_name, *args, **kwargs)
        # add parameters, inputs and outputs here

    def _validate_parameter(self, parameter: sr.Parameter) -> bool:
        if parameter.get_name() == "foo":
            # validate the incoming parameter value according to some criteria
            if sr.Parameter.get_value() < 0.0:
                # if the parameter is invalid, return False to ignore the new value
                return False
            if sr.Parameter.get_value() > 1.0:
                # if necessary, modify the incoming parameter value during validation
                sr.Parameter.set_value(1.0)
        # return True if the new parameter value should be applied
        return True

    def on_configure_callback(self) -> bool:
        # configuration steps before activation
        return True

    def on_activate_callback(self) -> bool:
        # activation steps before running
        return True

    def on_deactivate_callback(self) -> bool:
        # deactivation steps
        return True

    def on_step_callback(self):
        # do something periodically
        pass
