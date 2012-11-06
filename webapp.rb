dep 'app', :app_path, :app_repo, :domain do
  requires [
    'web app'.with(app_path, app_repo, domain),
    'freeswitch running'.with(app_path),
    'call server running'.with(app_path)
  ]
end

dep 'call server running', :app_path do
  met? {
    shell? "netstat -an | grep -E '^tcp.*[.:]8084 +.*LISTEN'"
  }
  meet {
    # TODO: use tmux session
    cd(app) {shell "./calls & disown"}
  }
end

dep 'web app', :app_path, :app_repo, :domain do
  requires [
    'imagemagick-dev',
    'libxml.managed',
    'libxslt.managed',
    'build-essential.managed',
    'postgres.managed'.with('9.1'),
    'redis-server.managed',
    'nginx running'.with(Dir.home, app_path, domain),
    # 'postgres running',
    # ssh "sudo babushka pirj:postgres.managed version=9.1"
    'rvm',
    'app running'.with(app_path, app_repo)
  ]
end

dep 'app running', :app_path, :app_repo do
  app_full_path = Dir.home / app_path
  requires [
    'app repo up to date'.with(app_full_path, app_repo),
    'webapp bundled'.with(app_full_path)
  ]

  met? {
    shell? "ls #{app_full_path}/tmp/pids/thin.pid"
  }
  meet {
    cd(app_path) { 
      shell "bundle exec thin -d -e production --chdir #{app_full_path} -S #{app_full_path}/thin.sock start"
    }
    # cd(app_path) {shell "bundle exec thin -d start"}
  }
end

dep 'rvm' do
  met? {
    shell 'ls .rvm'
  }
  meet {
    shell 'curl -L https://get.rvm.io | bash -s stable --ruby'
  }
end

dep 'app repo up to date', :app_path, :app_repo do
  requires 'app cloned'.with(app_path, app_repo)

  met? {
    cd(app_path) { shell? "git fetch origin; git log HEAD..origin/master --oneline"}
  }
  meet {
    cd(app_path) { shell "git pull origin master" }
  }
end

dep 'app cloned', :app_path, :app_repo do
  requires 'path exists'.with app_path

  met? {
    cd(app_path) { shell? "ls .git"}
  }
  meet {
    cd(app_path) { shell "git clone #{app_repo} ." }
  }
end

dep 'path exists', :path do
  met? {
    shell? "ls #{path}"
  }
  meet {
    cd("~") { shell "mkdir -p #{path}" }
  }
end

dep 'webapp bundled', :root do
  met? {
    shell? 'bundle check', :cd => root, :log => true
  }
  meet {
    # shell "bundle install --without 'development test'", :cd => root, :log => true
    shell "bundle install", :cd => root, :log => true
  }
end

# 'peerj:www user and group'

# . fail2ban

# babushka 'pirj:db'

# babushka 'pirj:nginx.logrotate'
# babushka 'pirj:rack.logrotate'

# babushka 'pirj:lamp stack removed'
# babushka 'pirj:postfix removed'
