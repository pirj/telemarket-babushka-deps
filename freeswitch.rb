dep 'freeswitch running', :config_path do
  requires 'freeswitch installed'
  met? {
    cd(config_path) {
      shell? 'ls freeswitch.pid'
    }
  }
  meet {
    cd(config_path) {
      shell "freeswitch -run . -log ./log -db . -conf . -nc"
    }
  }
end

dep 'freeswitch installed' do
  requires 'freeswitch packages built'
  met? {
    shell? 'which freeswitch'
  }
  meet {
    cd('freeswitch-deb') {
      sudo "dpkg -i libfreeswitch1_*.deb"
      sudo "dpkg -i freeswitch*.deb"
    }
  }
end

dep 'freeswitch packages built' do
  requires ['freeswitch repo cloned', 'freeswitch deps installed']
  met? {
    shell? 'ls freeswitch-deb'
  }
  meet {
    cd('freeswitch-src/debian') {
      shell './bootstrap.sh'
    }
    cd('freeswitch-src') {
      sudo 'mk-build-deps -i', :log => true
      sudo 'dpkg-buildpackage -b', :log => true
    }

    shell 'mkdir -p freeswitch-deb/dbg'
    shell "mv *dbg_*.deb freeswitch-deb/dbg"
    shell "mv *.deb freeswitch-deb"
  }
end

dep 'freeswitch deps installed' do
  requires [
    'devscripts.managed', 'equivs.managed', 'subversion.managed', 'build-essential.managed',
    'autoconf.managed', 'automake.managed', 'libtool.managed', 'libncurses5.managed',
    'libncurses5-dev.managed', 'libjpeg-dev.managed', 'python-dev.managed',
    'erlang-dev.managed', 'doxygen.managed', 'uuid-dev.managed', 'libgdbm-dev.managed',
    'libdb-dev.managed', 'bison.managed', 'ladspa-sdk.managed', 'libogg-dev.managed',
    'libasound2-dev.managed', 'libsnmp-dev.managed', 'libflac-dev.managed',
    'libvorbis-dev.managed', 'libvlc-dev.managed', 'default-jdk.managed',
    'gcj-jdk.managed', 'libperl-dev.managed', 'libyaml-dev.managed',
    'erlang-dev.managed', 'doxygen.managed', 'uuid-dev.managed', 'libgdbm-dev.managed',
    'libdb-dev.managed', 'bison.managed', 'ladspa-sdk.managed', 'libogg-dev.managed',
    'libasound2-dev.managed', 'libsnmp-dev.managed', 'libflac-dev.managed',
    'libvorbis-dev.managed', 'libvlc-dev.managed', 'default-jdk.managed',
    'gcj-jdk.managed', 'libperl-dev.managed', 'libyaml-dev.managed'
  ]
end

dep 'freeswitch repo cloned' do
  met? {
    shell? 'ls freeswitch-src'
  }
  meet {
    shell 'git clone git://git.freeswitch.org/freeswitch.git freeswitch-src'
  }
end

dep 'subversion.managed' do
  provides 'svn'
end

dep 'devscripts.managed' do
  provides 'mk-build-deps'
end

dep 'automake.managed'
dep 'autoconf.managed'
dep 'doxygen.managed'

['libtool', 'libncurses5', 'libncurses5-dev', 'libjpeg-dev', 'python-dev',
  'erlang-dev', 'doxygen', 'uuid-dev', 'libgdbm-dev', 'libdb-dev', 'bison',
  'ladspa-sdk', 'libogg-dev', 'libasound2-dev', 'libsnmp-dev', 'libflac-dev',
  'libvorbis-dev', 'libvlc-dev', 'default-jdk', 'gcj-jdk', 'libperl-dev',
  'libyaml-dev', 'erlang-dev', 'uuid-dev', 'libgdbm-dev',
  'libdb-dev', 'bison', 'ladspa-sdk', 'libogg-dev', 'libasound2-dev', 'libsnmp-dev',
  'libflac-dev', 'libvorbis-dev', 'libvlc-dev', 'default-jdk', 'gcj-jdk',
  'libperl-dev', 'libyaml-dev', 'equivs'].each do |package|
  dep "#{package}.managed" do
    provides []
  end
end
