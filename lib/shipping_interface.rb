class ShippingInterface
  def self.create_packages(raw_packages)
    packages = []
    raw_packages.each do |package|
      return false if package.values.any? { |value| value.nil? } || package["dimensions"].length < 3
      new_package = ActiveShipping::Package.new(
        package["weight"], package["dimensions"])
      packages << new_package
    end
    return packages
  end

  def self.create_location(location)
    return false if location.values.any? { |value| value.nil? }
    ActiveShipping::Location.new(
      country: location["country"],
      state: location["state"],
      city: location["city"],
      zip: location["zip"]
      )
  end
end
