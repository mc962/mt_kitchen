defmodule MTKitchenWeb.Manage.StepLive.StepComponent do
  use MTKitchenWeb, :live_component

  on_mount MTKitchenWeb.UserLiveAuth
end