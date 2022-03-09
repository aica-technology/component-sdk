#pragma once

#include <modulo_core/Component.hpp>


namespace template_component_package {
class CPPComponent : public modulo::core::Component {
public:
  explicit CPPComponent(const rclcpp::NodeOptions& options);

protected:
  bool on_configure() override;
  bool on_activate() override;
  void step() override;
};
}  // namespace template_component_package