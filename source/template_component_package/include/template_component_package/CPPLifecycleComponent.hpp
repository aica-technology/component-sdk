#pragma once

#include <modulo_components/LifecycleComponent.hpp>

namespace template_component_package {
class CPPLifecycleComponent : public modulo_components::LifecycleComponent {
public:
  explicit CPPLifecycleComponent(const rclcpp::NodeOptions& options);

protected:
  bool validate_parameter(const std::shared_ptr<state_representation::ParameterInterface>& parameter) override;

  bool on_configure_callback() override;
  bool on_activate_callback() override;
  bool on_deactivate_callback() override;
  void on_step_callback() override;
};
}  // namespace template_component_package