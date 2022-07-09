#include "template_component_package/CPPLifecycleComponent.h"

namespace template_component_package {
CPPLifecycleComponent::CPPLifecycleComponent(const rclcpp::NodeOptions& options) :
    modulo_components::LifecycleComponent(options, "CPPLifecycleComponent") {}

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