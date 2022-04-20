class SubdomainEventsService
  def initialize(object)
    @object = object
  end

  def track_event
    return if !Subdomain.current.api_plugin_events_enabled
    api_namespace = ApiNamespace.find_by(slug: ApiNamespace::REGISTERED_PLUGINS[:subdomain_events][:slug])
    # to-do this should not be an issue. see https://github.com/restarone/violet_rails/issues/327
    normalized_props = api_namespace.properties.class == Hash ? api_namespace.properties : JSON.parse(api_namespace.properties)
    api_properties = normalized_props.deep_symbolize_keys    
    object_type = @object.class.to_s
    case object_type
    when 'Message'
      # to-do plug in validations, make sure the same message doesnt have 2 events created after it 
      domain_with_fallback = Apartment::Tenant.current != 'public' ? Subdomain.current.name : Apartment::Tenant.current
      resource_properties = {
        model: {
          record_id: @object.id,
          record_type: object_type
        },
        representation: {
          body: "New Email @ #{Subdomain.current.name}.#{ENV['APP_HOST']} - from: #{@object.from}"
        }
      }
      ApiResourceSpawnJob.perform_async(api_namespace.id, resource_properties)
    end
    
  end
end