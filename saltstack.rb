require 'formula'

class Saltstack < Formula
  homepage 'http://saltstack.org/'
  url 'https://github.com/downloads/saltstack/salt/salt-0.10.5.tar.gz'
  sha1 '42796c7299e0000c250af2b3164fa77ef4f5e460'

  option 'with-deps', "Install python dependencies automatically"

  depends_on 'swig' => :build
  depends_on 'python'
  depends_on 'zeromq'

  if not build.include? 'with-deps'
    depends_on 'jinja2' => :python
    depends_on 'M2Crypto' => :python
    depends_on LanguageModuleDependency.new :python, 'PyCrypto', 'Crypto'
    depends_on LanguageModuleDependency.new :python, 'pyzmq', 'zmq'
    depends_on LanguageModuleDependency.new :python, 'PyYAML', 'yaml'
    depends_on LanguageModuleDependency.new :python, 'msgpack-python', 'msgpack'
  end

  def patches
    # set salt config dir to live under Homebrew's etc dir
    'https://raw.github.com/gist/4139822/74f6adab3846cccb27b691c26b04e44a92defa06/gistfile1.diff'
  end

  def install
    if build.include? 'with-deps'
      system "pip", "install", "-r", "requirements.txt"
    end

    # In order to install into the Cellar, the dir must exist and be in the PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    args = [
      "--no-user-cfg",
      "--verbose",
      "install",
      "--force",
      "--install-scripts=#{bin}",
      "--install-lib=#{temp_site_packages}",
      "--install-data=#{share}",
      "--install-headers=#{include}",
    ]

    system "python", "-s", "setup.py", *args
  end

  def which_python
    # Update this once we have something like [this](https://github.com/mxcl/homebrew/issues/11204)
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end

  def test
    system "salt --version"
  end
end
