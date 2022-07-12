#include "template_component_package/CPPLifecycleComponent.hpp"

namespace template_component_package {
CPPLifecycleComponent::CPPLifecycleComponent(const rclcpp::NodeOptions& options) :
    modulo_components::LifecycleComponent(options, "CPPLifecycleComponent") {
  // add parameters, inputs and outputs here
}

bool
CPPLifecycleComponent::validate_parameter(const std::shared_ptr<state_representation::ParameterInterface>& parameter) {
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

bool CPPLifecycleComponent::on_configure_callback() {
  // configuration steps before activation
  return true;
}

bool CPPLifecycleComponent::on_activate_callback() {
  // activation steps before running
  return true;
}

bool CPPLifecycleComponent::on_deactivate_callback() {
  // deactivation steps
  return true;
}

void CPPLifecycleComponent::on_step_callback() {
  // do something periodically
}

} // namespace template_component_package

#include "rclcpp_components/register_node_macro.hpp"

RCLCPP_COMPONENTS_REGISTER_NODE(template_component_package::CPPLifecycleComponent)