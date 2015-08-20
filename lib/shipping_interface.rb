class ShippingInterface
  def self.create_packages(raw_packages)
    packages = []
    raw_packages.each do |package|
      new_package = ActiveShipping::Package.new(
        package["weight"], package["dimensions"])
      packages << new_package
    end
    return packages
  end

  def self.create_location(location)
    ActiveShipping::Location.new(
      country: location["country"],
      state: location["state"],
      city: location["city"],
      zip: location["zip"]
      )
  end
end
