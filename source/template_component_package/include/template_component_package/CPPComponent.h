#pragma once

#include <modulo_components/Component.hpp>

namespace template_component_package {
class CPPComponent : public modulo_components::Component {
public:
  explicit CPPComponent(const rclcpp::NodeOptions& options);
};
}  // namespace template_component_package