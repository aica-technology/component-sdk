#include "template_component_package/CPPComponent.hpp"

namespace template_component_package {
CPPComponent::CPPComponent(const rclcpp::NodeOptions& options) :
    modulo_components::Component(options, "CPPComponent") {
  // add parameters, inputs and outputs here
}

bool CPPComponent::validate_parameter(const std::shared_ptr<state_representation::ParameterInterface>& parameter) {
  if (parameter->get_name() == "foo") {
    // validate the incoming parameter value according to some criteria
    auto value = parameter->get_parameter_value<double>();
    if (value < 0.0) {
      // if the parameter is invalid, return false to ignore the new value
      return false;
    }
    if (value > 1.0) {
      // if necessary, modify the incoming parameter value during validation
      parameter->set_parameter_value<double>(1.0);
    }
  }
  // return true if the new parameter value should be applied
  return true;
}

bool CPPComponent::on_execute_callback() {
  // If the component needs to do any post-construction behavior, invoke `execute()`
  // at the end of the constructor, which will trigger this callback in a separate thread.
  // This is only necessary when the behavior would otherwise block the constructor from completing
  // in a timely manner, such as some time-intensive computation or waiting for an external trigger.

  // return true if the execution was successful, false otherwise
  return true;
}

} // namespace template_component_package

#include "rclcpp_components/register_node_macro.hpp"

RCLCPP_COMPONENTS_REGISTER_NODE(template_component_package::CPPComponent)