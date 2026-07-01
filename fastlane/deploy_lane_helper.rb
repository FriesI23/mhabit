module DeployLaneHelper
  module_function

  def option_enabled?(options, key, default:)
    value = options[key]
    return default if value.nil?
    return value if value == true || value == false

    case value.to_s.strip.downcase
    when "true", "1", "yes", "y"
      true
    when "false", "0", "no", "n"
      false
    else
      default
    end
  end

  def dry_run_enabled?(options)
    return true if option_enabled?(options, :dry_run, default: false)

    ENV["DRY_RUN"].to_s == "1"
  end

  # Precheck cannot check In-App Purchases when authenticated with an App Store
  # Connect API Key (as opposed to Apple ID login).  Return false when the API
  # Key env var is set so that precheck skips the IAP check in CI.
  def precheck_include_in_app_purchases?
    ENV["APP_STORE_CONNECT_API_KEY_KEY_ID"].nil?
  end

  def report_dry_run_skip(action:, artifact: nil, track: nil, locales: nil,
                          metadata_path: nil)
    FastlaneCore::UI.important("[dry_run] Skipping #{action}")
    FastlaneCore::UI.message("artifact: #{artifact}") if artifact
    FastlaneCore::UI.message("track: #{track}") if track
    FastlaneCore::UI.message("locales: #{locales.join(', ')}") if locales && !locales.empty?
    FastlaneCore::UI.message("metadata_path: #{metadata_path}") if metadata_path
  end

  # Unlike report_dry_run_skip, this does NOT skip the call: the public track still
  # invokes upload_to_app_store with verify_only: true, which does a real (read-only)
  # binary validation against App Store Connect without submitting for review.
  def report_dry_run_verify_only(artifact:, track:)
    FastlaneCore::UI.important(
      "[dry_run] track: #{track} - calling upload_to_app_store with verify_only: true " \
      "(validates #{artifact} against App Store Connect, does not submit for review)"
    )
  end
end