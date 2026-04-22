defmodule PlausibleWeb.URL do
  @moduledoc false

  alias Plausible.Site

  def base_url do
    url_config = PlausibleWeb.Endpoint.config(:url)

    %URI{
      scheme: to_string(Keyword.get(url_config, :scheme, "http")),
      host: Keyword.fetch!(url_config, :host),
      port: Keyword.get(url_config, :port),
      path: Keyword.get(url_config, :path, "/")
    }
    |> URI.to_string()
    |> String.trim_trailing("/")
  end

  def path(path) do
    PlausibleWeb.Endpoint.config(:url)
    |> Keyword.get(:path, "/")
    |> Path.join(path)
  end

  def url(path) do
    Path.join(base_url(), path)
  end

  def site_path(%Site{} = site), do: site_path(site, nil, [])
  def site_path(%Site{} = site, extra), do: site_path(site, extra, [])

  def site_path(%Site{} = site, extra, params) do
    site
    |> site_route_base()
    |> append_path(extra)
    |> path()
    |> append_query(params)
  end

  def site_url(%Site{} = site), do: site_url(site, nil, [])
  def site_url(%Site{} = site, extra), do: site_url(site, extra, [])

  def site_url(%Site{} = site, extra, params) do
    site
    |> site_route_base()
    |> append_path(extra)
    |> url()
    |> append_query(params)
  end

  def site_action_path(%Site{} = site), do: site_action_path(site, nil, [])
  def site_action_path(%Site{} = site, extra), do: site_action_path(site, extra, [])

  def site_action_path(%Site{} = site, extra, params) do
    site
    |> site_action_route_base()
    |> append_path(extra)
    |> path()
    |> append_query(params)
  end

  def site_action_url(%Site{} = site), do: site_action_url(site, nil, [])
  def site_action_url(%Site{} = site, extra), do: site_action_url(site, extra, [])

  def site_action_url(%Site{} = site, extra, params) do
    site
    |> site_action_route_base()
    |> append_path(extra)
    |> url()
    |> append_query(params)
  end

  def site_route_by_id?(%Site{domain: domain}) when is_binary(domain) do
    String.contains?(domain, "/")
  end

  def site_route_by_id?(_site), do: false

  def site_param(%Site{} = site) do
    if site_route_by_id?(site) do
      "s/#{site.id}"
    else
      site.domain
    end
  end

  defp site_route_base(%Site{} = site), do: site_param(site)
  defp site_action_route_base(%Site{} = site), do: Path.join("sites", site_param(site))

  defp append_path(base, nil), do: base
  defp append_path(base, ""), do: base
  defp append_path(base, extra), do: Path.join(base, extra)

  defp append_query(path, params) when params in [%{}, []], do: path

  defp append_query(path, params) do
    encoded = URI.encode_query(params)

    if encoded == "" do
      path
    else
      path <> "?" <> encoded
    end
  end
end
