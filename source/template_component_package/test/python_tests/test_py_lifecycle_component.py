import pytest

from template_component_package.py_lifecycle_component import PyLifecycleComponent


@pytest.fixture()
def py_lifecycle_component():
    yield PyLifecycleComponent('py_lifecycle_component')


def test_construction(ros_context):
    component = PyLifecycleComponent('py_lifecycle_component')
    assert component.get_name() == 'py_lifecycle_component'


def test_configuration_activation(ros_exec, make_lifecycle_change_client, py_lifecycle_component):
    change_client = make_lifecycle_change_client('py_lifecycle_component')
    ros_exec.add_node(change_client)
    ros_exec.add_node(py_lifecycle_component)
    change_client.configure(ros_exec, timeout_sec=0.5)
    change_client.activate(ros_exec, timeout_sec=0.5)
