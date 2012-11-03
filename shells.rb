dep 'zsh', :username do
  username.default!(shell('whoami'))
  requires 'zsh.shell_setup'
  met? { shell("sudo su - '#{username}' -c 'echo $SHELL'") == which('zsh') }
  meet { sudo("chsh -s '#{which('zsh')}' #{username}") }
end

dep 'zsh.shell_setup' do
  requires 'zsh.bin'
end

dep 'zsh.bin'
