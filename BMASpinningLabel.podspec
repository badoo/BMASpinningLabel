Pod::Spec.new do |s|
  s.name         = "BMASpinningLabel"
  s.version      = "1.0.0"
  s.summary      = "Label with..."
  s.description  = <<-DESC
                   BMASpinningLabel is an UI component which provides easy way for displaying and animating text inside it.
                   Text changes animated as 'spins' (either downwards or upwards).
                   DESC
  s.homepage     = "https://github.com/badoo/BMASpinningLabel.git"
  s.license      = { :type => "MIT"}
  s.author       = { "Viacheslav Radchenko"  => "viacheslav.radchenko@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/badoo/BMASpinningLabel.git", :tag => s.version.to_s }
  s.source_files = "BMASpinningLabel/*"
  s.public_header_files = "BMASpinningLabel/*.h"
  s.requires_arc = true
end
