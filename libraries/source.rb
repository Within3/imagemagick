module Imagemagick
  module Source

    # Get the URL hosting the given version of ImageMagick
    #
    # @param [String] version The version of ImageMagick
    # @returns [String] the download URL for the version's source archive
    def imagemagick_source_url(version)
      versions = version.split(".")
      parts = ["http://downloads.sourceforge.net/project/imagemagick/old-sources"]
      parts << "#{versions.first}.x"
      parts << "#{versions.first}.#{versions[1]}"
      parts << "#{imagemagick_source_archive(version)}.tar.gz"
      parts.join("/")
    end

    # The base name of the source archive for the given version of ImageMagick
    #
    # @param [String] version The version of ImageMagick
    # @returns [String] the name of the source archive for the version
    def imagemagick_source_archive(version)
      parts = ["ImageMagick", version]
      if not version.end_with?(/-\d+/)
        parts << "10"
      end
      parts.join("-")
    end

  end
end
