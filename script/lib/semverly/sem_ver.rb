# The SemVer class provides parsing and sorting for version strings that
# comply with the {Semantic Versioning 2.0.0}[http://semver.org/] specification.
class SemVer
  include Comparable

  # The major version (_x_ in +x.y.z+).
  attr_accessor :major

  # The minor version (_y_ in +x.y.z+).
  attr_accessor :minor

  # The patch version (_z_ in +x.y.z+).
  attr_accessor :patch

  # Pre-release version tag (optional).
  attr_accessor :prerelease

  # Version metadata (optional).
  attr_accessor :metadata

  # Creates a new SemVer instance.
  #
  # Initialization requires at least one argument: the major version number.
  # The minor and patch versions are optional and are +0+ if not supplied. The
  # prerelease and metadata parts are also optional and blank if not supplied.
  def initialize(major, minor = 0, patch = 0, prerelease = nil, metadata = nil)
    self.major = major
    self.minor = minor
    self.patch = patch
    self.prerelease = prerelease
    self.metadata = metadata
  end

  # Parses a SemVer-compliant string into its component parts.
  #
  # @param string [String] the version identifier to parse
  # @return [SemVer] A +SemVer+ instance or +nil+ if the string is not SemVer compliant.
  def self.parse(string)
    re = Regexp.new('\Av?(?<major>\d+)
                         (\.(?<minor>\d+))?
                         (\.(?<patch>\d+))?
                         (-(?<prerelease>[0-9A-Za-z.-]+))?
                         (\+(?<metadata>[0-9A-Za-z.-]+))?\z', Regexp::EXTENDED)
    matches = re.match(string)
    return nil if matches.nil?

    major = matches['major'].to_i
    minor = matches['minor'].to_i
    patch = matches['patch'].to_i

    if prerelease = matches['prerelease']
      return nil if prerelease.split('.').any? { |part| part.nil? || part == '' }
    end

    if metadata = matches['metadata']
      return nil if metadata.split('.').any? { |part| part.nil? || part == '' }
    end

    new(major, minor, patch, prerelease, metadata)
  end

  # Generates a version string from SemVer parts.
  #
  # @return [String] The version identifier.
  def to_s
    s = "#{major}.#{minor}.#{patch}"
    s << "-#{prerelease}" unless prerelease.nil?
    s << "+#{metadata}" unless metadata.nil?
    s
  end

  # Compares two SemVer versions.
  #
  # @param other [SemVer] another +SemVer+ instance to compare with the receiver
  # @return [Fixnum] -1, 0 or +1 depending on if this instance is less than, equal to or greater than +other+.
  def <=>(other)
    result = [self.major, self.minor, self.patch] <=> [other.major, other.minor, other.patch]
    result = compare_prerelease(other) if result == 0
    result
  end

  private

  def compare_prerelease(other)
    return 0 if prerelease.nil? && other.prerelease.nil?
    return -1 if other.prerelease.nil?
    return 1 if prerelease.nil?

    my_parts = prerelease.split('.')
    other_parts = other.prerelease.split('.')

    loop do
      my_part = my_parts.shift
      other_part = other_parts.shift

      return 0 if my_part.nil? && other_part.nil?
      return -1 if my_part.nil?
      return 1 if other_part.nil?

      mine_numeric = my_part =~ /\A\d+\z/
      other_numeric = other_part =~ /\A\d+\z/
      if mine_numeric && other_numeric
        result = my_part.to_i <=> other_part.to_i
        return result unless result == 0
      elsif mine_numeric
        return -1
      elsif other_numeric
        return 1
      else
        result = my_part <=> other_part
        return result unless result == 0
      end
    end
  end
end
