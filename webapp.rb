dep 'web app', :app_path, :app_repo do
  requires [
    'imagemagick.managed',
    # 'nginx running',
    # 'postgres running',
    # ssh "sudo babushka pirj:postgres.managed version=9.1"
    'rvm',
    # 'rvm ruby 1.9.3',
    'app running'.with(app_path, app_repo)
  ]
end

dep 'app running', :app_path, :app_repo do
  requires [
    'app cloned'.with(app_path, app_repo),
    'app bundled'.with(app_path)
  ]

  met? {
    shell "curl localhost:80 | grep 'head'"
  }
  meet {
    # shell "thin -d -e production --chdir /home/pirj/production -S /home/pirj/production.sock start" 
    shell "thin -d -e production --chdir #{app_path} start" 
  }
end

dep 'rvm' do
  met? {
    shell 'which rvm'
  }
  meet {
    shell 'curl -L https://get.rvm.io | bash -s stable --ruby'
  }
end

dep 'app cloned', :app_path, :app_repo do
  requires 'path exists'.with app_path

  met? {
    cd(app_path) { shell? "git fetch; git log HEAD.. --oneline"}
  }
  meet {
    cd(app_path) { shell "git pull" }
  }
end

dep 'app bundled', :app_path do
  met? {
    cd(app_path) { shell? "bundle check" }
  }
  meet {
    cd(app_path) { shell "bundle install" }
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
