
class CloudProviderPresenter < Keynote::Presenter
  presents :cloud_provider

  delegate :id, :name, :owner, :description, :config,
           to: :cloud_provider

  def name_link
    link_to(cloud_provider.name, cloud_provider)
  end

end
