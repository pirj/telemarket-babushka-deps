dep 'web app', :app_path, :app_repo do
  requires [
    'imagemagick-dev',
    'libxml.managed',
    'libxslt.managed',
    'build-essential.managed',
    'postgres.managed'.with('9.1'),
    'redis-server.managed',
    # 'nginx running',
    # 'postgres running',
    # ssh "sudo babushka pirj:postgres.managed version=9.1"
    'rvm',
    # 'rvm ruby 1.9.3',
    'app running'.with("~/#{app_path}", app_repo)
  ]
end

dep 'app running', :app_path, :app_repo do
  requires [
    'app repo up to date'.with(app_path, app_repo),
    'webapp bundled'.with(app_path)
  ]

  met? {
    shell "curl localhost:80 | grep 'head'"
  }
  meet {
    # shell "thin -d -e production --chdir /home/pirj/production -S /home/pirj/production.sock start" 
    cd(app_path) {shell "bundle exec thin -d -e production start"}
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

# restrict ssh for deployer, use su - to log in
# override `` in ssh block, provide stout/stderr
 # . freeswitch
 # . fail2ban
 # . redis
 # . 
 # . bundle
 # . run
 # ... rest of interesting deps

# babushka 'pirj:db'

# babushka 'pirj:nginx.logrotate'
# babushka 'pirj:rack.logrotate'

# ? babushka 'pirj:dnsmasq'

# babushka 'pirj:apt packages removed'
# babushka 'pirj:lamp stack removed'
# babushka 'pirj:postfix removed'

# babushka 'pirj:ready for update.repo'
# babushka 'pirj:up to date.repo'

# babushka 'pirj:before deploy'
# babushka 'pirj:on deploy'
# babushka 'pirj:after deploy'

# babushka 'pirj:on correct branch.repo'

# babushka 'pirj:maintenance page up'
# babushka 'pirj:maintenance page down'
