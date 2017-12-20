#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

#リポジトリを設定するためのrepoファイルを作成
#templateリソース：sourceで指定したファイル内容をNodeに作成する
template 'nginx.repo' do
  path    '/etc/yum.repos.d/nginx.repo'
  source  'nginx.repo.erb'
  mode    0644
  user    'root'
  group   'root'
end

#nginxをインストールする
#packageリソース：yumでインストールする
package 'nginx' do
    action [ :install ]
end

#nginxのサービスを起動する
#serviceリソース：サービスの管理を行う
service 'nginx' do
    supports [ :restart, :reload ]
    action [ :enable, :start ]
end
