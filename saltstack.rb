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
    { # Change paths to match Homebrew standards
      :p0 => DATA
    }
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
__END__

# Change paths to match Homebrew standards. Generated with the following script:
#
# PATCHFILES="salt/config.py salt/utils/parsers.py salt/client.py"
# sed -i .orig \
#   -e 's@/etc/@HOMEBREW_PREFIX/etc/@g' \
#   -e 's@/var/@HOMEBREW_PREFIX/var/@g' \
#   -e 's@/srv/@HOMEBREW_PREFIX/srv/@g' \
#   $PATCHFILES
# for f in $PATCHFILES; do diff -u $f.orig $f; done
#

--- salt/config.py.orig	2012-11-09 21:02:11.000000000 -0800
+++ salt/config.py	2013-03-05 12:19:00.000000000 -0800
@@ -39,7 +39,7 @@
     if not isinstance(file_roots, dict):
         log.warning('The file_roots parameter is not properly formatted,'
                     ' using defaults')
-        return {'base': ['/srv/salt']}
+        return {'base': ['HOMEBREW_PREFIX/srv/salt']}
     for env, dirs in list(file_roots.items()):
         if not isinstance(dirs, list) and not isinstance(dirs, tuple):
             file_roots[env] = []
@@ -156,12 +156,12 @@
             'master_finger': '',
             'user': 'root',
             'root_dir': '/',
-            'pki_dir': '/etc/salt/pki',
+            'pki_dir': 'HOMEBREW_PREFIX/etc/salt/pki',
             'id': socket.getfqdn(),
-            'cachedir': '/var/cache/salt',
+            'cachedir': 'HOMEBREW_PREFIX/var/cache/salt',
             'cache_jobs': False,
             'conf_file': path,
-            'sock_dir': '/var/run/salt',
+            'sock_dir': 'HOMEBREW_PREFIX/var/run/salt',
             'backup_mode': '',
             'renderer': 'yaml_jinja',
             'failhard': False,
@@ -173,10 +173,10 @@
             'top_file': '',
             'file_client': 'remote',
             'file_roots': {
-                'base': ['/srv/salt'],
+                'base': ['HOMEBREW_PREFIX/srv/salt'],
                 },
             'pillar_roots': {
-                'base': ['/srv/pillar'],
+                'base': ['HOMEBREW_PREFIX/srv/pillar'],
                 },
             'hash_type': 'md5',
             'external_nodes': '',
@@ -194,7 +194,7 @@
             'ipc_mode': 'ipc',
             'tcp_pub_port': 4510,
             'tcp_pull_port': 4511,
-            'log_file': '/var/log/salt/minion',
+            'log_file': 'HOMEBREW_PREFIX/var/log/salt/minion',
             'log_level': None,
             'log_level_logfile': None,
             'log_datefmt': __dflt_log_datefmt,
@@ -276,21 +276,21 @@
             'publish_port': '4505',
             'user': 'root',
             'worker_threads': 5,
-            'sock_dir': '/var/run/salt',
+            'sock_dir': 'HOMEBREW_PREFIX/var/run/salt',
             'ret_port': '4506',
             'timeout': 5,
             'keep_jobs': 24,
             'root_dir': '/',
-            'pki_dir': '/etc/salt/pki',
-            'cachedir': '/var/cache/salt',
+            'pki_dir': 'HOMEBREW_PREFIX/etc/salt/pki',
+            'cachedir': 'HOMEBREW_PREFIX/var/cache/salt',
             'file_roots': {
-                'base': ['/srv/salt'],
+                'base': ['HOMEBREW_PREFIX/srv/salt'],
                 },
             'master_roots': {
-                'base': ['/srv/salt-master'],
+                'base': ['HOMEBREW_PREFIX/srv/salt-master'],
                 },
             'pillar_roots': {
-                'base': ['/srv/pillar'],
+                'base': ['HOMEBREW_PREFIX/srv/pillar'],
                 },
             'ext_pillar': [],
             # TODO - Set this to 2 by default in 0.10.5
@@ -317,14 +317,14 @@
             'job_cache': True,
             'ext_job_cache': '',
             'minion_data_cache': True,
-            'log_file': '/var/log/salt/master',
+            'log_file': 'HOMEBREW_PREFIX/var/log/salt/master',
             'log_level': None,
             'log_level_logfile': None,
             'log_datefmt': __dflt_log_datefmt,
             'log_fmt_console': __dflt_log_fmt_console,
             'log_fmt_logfile': __dflt_log_fmt_logfile,
             'log_granular_levels': {},
-            'pidfile': '/var/run/salt-master.pid',
+            'pidfile': 'HOMEBREW_PREFIX/var/run/salt-master.pid',
             'cluster_masters': [],
             'cluster_mode': 'paranoid',
             'range_server': 'range:80',
@@ -333,7 +333,7 @@
             'state_output': 'full',
             'nodegroups': {},
             'cython_enable': False,
-            'key_logfile': '/var/log/salt/key',
+            'key_logfile': 'HOMEBREW_PREFIX/var/log/salt/key',
             'verify_env': True,
             'permissive_pki_access': False,
             'default_include': 'master.d/*.conf',
--- salt/utils/parsers.py.orig	2012-11-15 20:13:34.000000000 -0800
+++ salt/utils/parsers.py	2013-03-05 12:19:00.000000000 -0800
@@ -167,7 +167,7 @@
 
     def _mixin_setup(self):
         self.add_option(
-            '-c', '--config-dir', default='/etc/salt',
+            '-c', '--config-dir', default='HOMEBREW_PREFIX/etc/salt',
             help=('Pass in an alternative configuration directory. Default: '
                   '%default')
         )
@@ -374,7 +374,7 @@
     def _mixin_setup(self):
         self.add_option(
             '--pid-file', dest='pidfile',
-            default='/var/run/{0}.pid'.format(self.get_prog_name()),
+            default='HOMEBREW_PREFIX/var/run/{0}.pid'.format(self.get_prog_name()),
             help=('Specify the location of the pidfile. Default: %default')
         )
 
@@ -903,7 +903,7 @@
 
         self.add_option(
             '--key-logfile',
-            default='/var/log/salt/key',
+            default='HOMEBREW_PREFIX/var/log/salt/key',
             help=('Send all output to a file. Default is %default')
         )
 
--- salt/client.py.orig	2012-11-12 21:23:37.000000000 -0800
+++ salt/client.py	2013-03-05 12:19:00.000000000 -0800
@@ -68,7 +68,7 @@
     '''
     Connect to the salt master via the local server and via root
     '''
-    def __init__(self, c_path='/etc/salt'):
+    def __init__(self, c_path='HOMEBREW_PREFIX/etc/salt'):
         self.opts = salt.config.client_config(c_path)
         self.serial = salt.payload.Serial(self.opts)
         self.salt_user = self.__get_user()
@@ -937,7 +937,7 @@
     '''
     Create an object used to call salt functions directly on a minion
     '''
-    def __init__(self, c_path='/etc/salt/minion'):
+    def __init__(self, c_path='HOMEBREW_PREFIX/etc/salt/minion'):
         self.opts = salt.config.minion_config(c_path)
         self.sminion = salt.minion.SMinion(self.opts)
 
