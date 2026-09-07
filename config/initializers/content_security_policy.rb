# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self, "https://mcp.figma.com", :unsafe_inline
    policy.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com"
    policy.connect_src :self, "https://mcp.figma.com"
    policy.frame_src   :self, "https://mcp.figma.com"
  end
end
