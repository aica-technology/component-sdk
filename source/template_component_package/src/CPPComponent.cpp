#include "template_component_package/CPPComponent.h"

namespace template_component_package {
CPPComponent::CPPComponent(const rclcpp::NodeOptions& options) :
    modulo_components::Component(options, "CPPComponent") {}
} // namespace template_component_package

#include "rclcpp_components/register_node_macro.hpp"

RCLCPP_COMPONENTS_REGISTER_NODE(template_component_package::CPPComponent)