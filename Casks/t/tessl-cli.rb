cask "tessl-cli" do
  version "0.22.0"
  sha256 "bce2d6073ec32021540d1e34ec9d0ee88b0e585759b92e39d9a1fd00d0f16f08"

  url "https://registry.npmjs.org/@tessl/cli/-/cli-#{version}.tgz"
  name "Tessl CLI"
  desc "AI Native Development Platform CLI"
  homepage "https://tessl.io"

  depends_on formula: "node"

  installer script: {
    executable: "package/install.sh",
    args:       ["#{caskroom_path}/#{version}"],
  }

  binary "#{caskroom_path}/#{version}/bin/tessl"

  preflight do
    # Create installation script
    installer_script = "#{staged_path}/package/install.sh"
    FileUtils.mkdir_p "#{staged_path}/package"
    
    File.write installer_script, <<~EOS
      #!/bin/sh
      set -e
      
      # Extract and install the npm package
      cd "#{staged_path}/package"
      npm install --prefix "#{caskroom_path}/#{version}" @tessl/cli@#{version}
      
      # Find the actual binary location and create symlink
      mkdir -p "#{caskroom_path}/#{version}/bin"
      
      # Create symlink to the actual binary (dist/bundle.mjs)
      ln -sf "../node_modules/@tessl/cli/dist/bundle.mjs" "#{caskroom_path}/#{version}/bin/tessl"
      
      # Make the binary executable
      chmod +x "#{caskroom_path}/#{version}/bin/tessl"
    EOS
    
    FileUtils.chmod 0755, installer_script
  end

  uninstall script: {
    executable: "rm",
    args:       ["-rf", "#{caskroom_path}/#{version}", "~/.tessl"],
  }

  zap trash: "~/.tessl"

  caveats <<~EOS
    Tessl CLI has been installed to #{caskroom_path}/#{version}.
    Make sure Node.js is installed: brew install node
  EOS
end
  