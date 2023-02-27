import pytest

from template_component_package.py_component import PyComponent


@pytest.fixture()
def py_component():
    yield PyComponent('py_component')


def test_construction(ros_context):
    component = PyComponent('py_component')
    assert component.get_name() == 'py_component'

def test_execute_finished(ros_exec, make_predicates_listener, py_component):
    listener = make_predicates_listener('py_component', ['is_finished'])
    py_component.execute()
    ros_exec.add_node(listener)
    ros_exec.add_node(py_component)
    ros_exec.spin_until_future_complete(listener.predicates_future, 0.5)
    assert listener.predicates_future.done() and listener.predicates_future.result()
