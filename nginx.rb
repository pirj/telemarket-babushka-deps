dep 'nginx running', :user_home, :app_name, :domain do
  requires 'nginx configured'.with(user_home, app_name, domain)
  met? {
    shell? "netstat -an | grep -E '^tcp.*[.:]80 +.*LISTEN'"
  }
  meet do
    sudo '/etc/init.d/nginx start'
  end
end

dep 'nginx configured', :user_home, :app_name, :domain do
  www_name = 'www-data'
  requires [
    'nginx-light.managed',
    'www user and group'.with(www_name)
  ]
  met? {
    Babushka::Renderable.new("/etc/nginx/nginx.conf").from?(dependency.load_path.parent / "nginx/nginx.conf.erb")
  }
  meet {
    render_erb 'nginx/nginx.conf.erb', :to => "/etc/nginx/nginx.conf", :sudo => true
  }
end

dep 'nginx-light.managed' do
  provides 'nginx'
end

dep 'www user and group', :www_name do
  met? {
    '/etc/passwd'.p.grep(/^#{www_name}\:/) and
    '/etc/group'.p.grep(/^#{www_name}\:/)
  }
  meet {
    sudo "groupadd #{www_name}"
    sudo "useradd -g #{www_name} #{www_name} -s /bin/false"
  }
end
