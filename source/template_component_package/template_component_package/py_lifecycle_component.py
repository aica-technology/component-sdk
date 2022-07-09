from modulo_components.lifecycle_component import LifecycleComponent


class PyLifecycleComponent(LifecycleComponent):
    def __init__(self, node_name: str, *args, **kwargs):
        super().__init__(node_name, *args, **kwargs)

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
