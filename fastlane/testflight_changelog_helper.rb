module TestflightChangelogHelper
  ANDROID_TESTFLIGHT_LOCALE_MAP = {
    "en-US" => "en-US",
    "zh-Hans" => "zh-CN"
  }.freeze

  module_function

  def read_flutter_build_number(pubspec_path)
    version_line = File.readlines(pubspec_path).find do |line|
      line.start_with?("version:")
    end
    FastlaneCore::UI.user_error!("Missing version in #{pubspec_path}") if version_line.nil?

    match = version_line.match(/\+(\d+)/)
    FastlaneCore::UI.user_error!("Missing build number in #{pubspec_path}") if match.nil?

    match[1]
  end

  def load(metadata_dir:, pubspec_path:, build_number: nil)
    build_number ||= read_flutter_build_number(pubspec_path)
    localized_build_info = {}

    ANDROID_TESTFLIGHT_LOCALE_MAP.each do |testflight_locale, android_locale|
      changelog_path = File.join(
        metadata_dir,
        android_locale,
        "changelogs",
        "#{build_number}.txt"
      )
      next unless File.file?(changelog_path)

      whats_new = File.read(changelog_path).strip
      next if whats_new.empty?

      localized_build_info[testflight_locale] = { whats_new: whats_new }
    end

    if localized_build_info.empty?
      FastlaneCore::UI.user_error!(
        "No Android changelog files found for build #{build_number} under #{metadata_dir}"
      )
    end

    changelog = localized_build_info["en-US"]&.dig(:whats_new)
    changelog ||= localized_build_info.values.first[:whats_new]
    [changelog, localized_build_info]
  end
end