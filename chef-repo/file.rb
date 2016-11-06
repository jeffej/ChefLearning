file '/etc/motd' do
  action :create
  mode '0755'
  group 'root'
  owner 'root'
end