from modulo_components.component import Component
import state_representation as sr


class PyComponent(Component):
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

    def on_execute_callback(self) -> bool:
        # If the component needs to do any post-construction behavior, invoke `self.execute()`
        # at the end of the constructor, which will trigger this callback in a separate thread.
        # This is only necessary when the behavior would otherwise block the constructor from completing
        # in a timely manner, such as some time-intensive computation or waiting for an external trigger.

        # return True if the execution was successful, False otherwise
        return True
