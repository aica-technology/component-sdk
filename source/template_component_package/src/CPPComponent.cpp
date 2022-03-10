#include "template_component_package/CPPComponent.h"


namespace template_component_package {
CPPComponent::CPPComponent(const rclcpp::NodeOptions& options) : modulo::core::Component(options) {}

bool CPPComponent::on_configure() {
  // configuration steps before activation
  return true;
}

bool CPPComponent::on_activate() {
  // activation steps before running
  return true;
}

void CPPComponent::step() {
  // do something periodically
}
} // namespace template_component_package

#include "rclcpp_components/register_node_macro.hpp"

RCLCPP_COMPONENTS_REGISTER_NODE(template_component_package::CPPComponent)