module TestflightChangelogHelper
  ANDROID_TESTFLIGHT_LOCALE_MAP = {
    "en-US" => "en-US",
    "zh-Hans" => "zh-CN"
  }.freeze

  module_function

  def android_metadata_dir(flavor)
    flavor_dir = File.expand_path(
      "../android/app/src/#{flavor}/fastlane/metadata/android",
      __dir__
    )
    return flavor_dir if Dir.exist?(flavor_dir)

    shared_dir = File.expand_path("metadata/android", __dir__)
    return shared_dir if Dir.exist?(shared_dir)

    FastlaneCore::UI.user_error!("No Android changelog metadata found for flavor #{flavor}")
  end

  def read_flutter_build_number(pubspec_path)
    version_line = File.readlines(pubspec_path).find do |line|
      line.start_with?("version:")
    end
    FastlaneCore::UI.user_error!("Missing version in #{pubspec_path}") if version_line.nil?

    match = version_line.match(/\+(\d+)/)
    FastlaneCore::UI.user_error!("Missing build number in #{pubspec_path}") if match.nil?

    match[1]
  end

  # Resolves the metadata/fallback dirs for a platform's fastlane lane and loads its changelog.
  # lane_dir should be the calling Fastfile's `__dir__` (e.g. "ios/fastlane", "macos/fastlane").
  def load_for_lane(lane_dir:, flavor:, pubspec_path:, build_number: nil)
    load(
      metadata_dir: android_metadata_dir(flavor),
      fallback_metadata_dir: File.join(lane_dir, "metadata"),
      pubspec_path: pubspec_path,
      build_number: build_number
    )
  end

  def load(metadata_dir:, pubspec_path:, fallback_metadata_dir: nil, build_number: nil)
    build_number ||= read_flutter_build_number(pubspec_path)
    localized_build_info = {}

    ANDROID_TESTFLIGHT_LOCALE_MAP.each do |testflight_locale, android_locale|
      changelog_path = File.join(
        metadata_dir,
        android_locale,
        "changelogs",
        "#{build_number}.txt"
      )
      whats_new = File.file?(changelog_path) ? File.read(changelog_path).strip : ""

      if whats_new.empty? && fallback_metadata_dir
        release_notes_path = File.join(fallback_metadata_dir, testflight_locale, "release_notes.txt")
        whats_new = File.read(release_notes_path).strip if File.file?(release_notes_path)
      end

      next if whats_new.empty?

      localized_build_info[testflight_locale] = { whats_new: whats_new }
    end

    if localized_build_info.empty?
      searched_dirs = [metadata_dir, fallback_metadata_dir].compact.join(" or ")
      FastlaneCore::UI.user_error!(
        "No changelog found for build #{build_number} under #{searched_dirs}"
      )
    end

    changelog = localized_build_info["en-US"]&.dig(:whats_new)
    changelog ||= localized_build_info.values.first[:whats_new]
    [changelog, localized_build_info]
  end
end