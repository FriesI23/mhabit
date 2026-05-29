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

  def report_dry_run_skip(action:, artifact: nil, track: nil, locales: nil,
                          metadata_path: nil)
    FastlaneCore::UI.important("[dry_run] Skipping #{action}")
    FastlaneCore::UI.message("artifact: #{artifact}") if artifact
    FastlaneCore::UI.message("track: #{track}") if track
    FastlaneCore::UI.message("locales: #{locales.join(', ')}") if locales && !locales.empty?
    FastlaneCore::UI.message("metadata_path: #{metadata_path}") if metadata_path
  end
end