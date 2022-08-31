defmodule MTKitchenWeb.ImageView do
  use MTKitchenWeb, :view

  def primary_picture(resource) do
    _classes = 'recipe-profile-img recipe-picture'
    _alt_text = 'Main picture of recipe food'

    if resource.primary_picture do
    else
    end
  end
end
