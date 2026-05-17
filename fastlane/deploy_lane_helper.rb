module DeployLaneHelper
  module_function

  def dry_run_enabled?(options)
    value = options[:dry_run]
    return true if value == true
    return true if value.to_s.downcase == "true"

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