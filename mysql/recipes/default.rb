#
# Cookbook:: mysql
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

#①yumリポジトリをインストール（変更なし）
rpm_package "mysql-community-release" do
  source "https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm"
  action :install
end

#②インストール！（変更なし）
package 'mysql-community-server' do
    action [ :install ]
end

#③サービスの起動や自動起動の設定（変更なし）
service 'mysqld' do
    supports [ :status, :restart, :reload ]
    action [ :enable, :start ]
end

#④mysql_secure_installationと同じことをやる
#ポイント：templateを使用してファイルの作成を行う。
root_password = node["mysql"]["root_password"]
template "/tmp/secure_installation.sql" do
  owner "root"
  group "root"
  mode 0644
  source "secure_installation.sql.erb"
  variables({
    :root_password => root_password,
  })
  notifies :run, "execute[secure_install]", :immediately
  not_if "mysql -u root -p#{root_password} -e 'show databases;'"
end

execute "secure_install" do
  command <<-"EOH"
    export Initial_PW=`grep 'password is generated' /var/log/mysqld.log |awk -F 'root@localhost: ' '{print $2}'`
    mysql -u root -p${Initial_PW}  --connect-expired-password -e "SET PASSWORD FOR 'root'@'localhost'             = PASSWORD('#{root_password}');"
      mysql -u root -p#{root_password}  < /tmp/secure_installation.sql
      rm /tmp/secure_installation.sql
  EOH
  action :nothing
end

#⑤marimoユーザーを作る
marimo_password = node["mysql"]["marimo_password"]
template "/tmp/create_user.sql" do
  owner "root"
  group "root"
  mode 0644
  source "create_user.sql.erb"
  variables({
    :marimo_password => marimo_password,
  })
  notifies :run, "execute[create_user]", :immediately
  not_if "mysql -u marimo -p#{marimo_password} -e 'show databases;'"
end

execute 'create_user' do
    command <<-"EOH"
      mysql -u root -p#{root_password} < /tmp/create_user.sql
      rm /tmp/create_user.sql
  EOH
    action :nothing
end

