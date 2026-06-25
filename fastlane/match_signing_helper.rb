module MatchSigningHelper
  module_function

  # match/sigh keep iOS profile env vars without a platform segment for
  # backwards compatibility, but namespace every other platform (e.g. macOS)
  # as `sigh_<app_identifier>_<type>_<platform>_<suffix>`.
  def appstore_env(app_identifier, suffix, platform: "ios")
    platform_segment = case platform.to_s
                        when "ios" then nil
                        when "tvos", "macos", "catalyst" then platform.to_s
                        else
                          FastlaneCore::UI.user_error!("Unsupported match platform: #{platform.inspect}")
                        end
    key = ["sigh", app_identifier, "appstore", platform_segment, suffix].compact.join("_")
    ENV[key]
  end
end
