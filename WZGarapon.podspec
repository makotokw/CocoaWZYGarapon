Pod::Spec.new do |s|
  s.name         = "WZGarapon"
  s.version      = "0.0.1"
  s.summary      = "Garapon API for iOS."
  s.homepage     = "https://github.com/makotokw/CocoaWZGarapon"
  s.license      = 'MIT'
  s.author       = { "makoto_kw" => "makoto.kw@gmail.com" }
  s.source       = { :git => "https://github.com/makotokw/CocoaWZGarapon.git", :tag => "0.0.1" }

  s.platform     = :ios, '5.0'
  s.source_files = 'Classes/*.{h,m}'
  s.requires_arc = true
end
