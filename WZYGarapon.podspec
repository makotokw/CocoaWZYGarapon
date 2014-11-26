Pod::Spec.new do |s|
  s.name         = "WZYGarapon"
  s.version      = "0.1"
  s.summary      = "Garapon API for iOS."
  s.homepage     = "https://github.com/makotokw/CocoaWZYGarapon"
  s.license      = 'MIT'
  s.author       = { "makoto_kw" => "makoto.kw@gmail.com" }
  s.source       = { :git => "https://github.com/makotokw/CocoaWZYGarapon.git", :tag => "v0.1" }

  s.platform     = :ios, '5.0'
  s.source_files = 'Classes/*.{h,m}'
  s.resources    = 'Resources/*.{lproj,bundle}'
  s.requires_arc = true
end
