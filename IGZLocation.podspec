Pod::Spec.new do |s|

  s.name         = "IGZLocation"
  s.version      = "1.0.2"
  s.summary      = "CLLocationManager Swift 3 wrapper with multiple closure handlers and delegates allowed, notifications, sequential geofencing, self-authorization and, of course, everything is testable. #InCodeWeTrust"
  s.description  = <<-DESC
  # IGZLocation
  CLLocationManager Swift 3 wrapper with multiple closure handlers and delegates allowed, notifications, sequential geofencing, self-authorization and, of course, everything is testable. #InCodeWeTrust
                   DESC

  s.homepage     = "https://github.com/intelygenz/IGZLocation"
  s.screenshots  = "https://raw.githubusercontent.com/intelygenz/IGZLocation/master/screenshot.gif"
  s.license      = "MIT"

  s.authors            = { "Alex Rupérez" => "alejandro.ruperez@intelygenz.com" }
  s.social_media_url   = "http://twitter.com/intelygenz"

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/intelygenz/IGZLocation.git", :tag => "#{s.version}" }

  s.source_files = "IGZLocation/*.swift"
  s.frameworks = "Foundation", "CoreLocation"

end