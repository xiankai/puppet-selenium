require 'spec_helper'

describe 'selenium', :type => :class do

  shared_examples 'selenium' do |params|
    # XXX need to test $url
    p = {
      :user         => 'selenium',
      :group        => 'selenium',
      :install_root => '/opt/selenium',
      :java         => 'java',
      :version      => '2.35.0',
      :url          => '',
    }

    if params
      p.merge!(params)
    end

    it do
      should contain_user(p[:user]).with_gid(p[:group])
      should contain_group(p[:group])
      should include_class('wget')
      should contain_class('selenium').with_version(p[:version])
      should contain_file("#{p[:install_root]}").with({
        'ensure' => 'directory',
        'owner'  => p[:user],
        'group'  => p[:group],
      })
      should contain_file("#{p[:install_root]}/jars").with({
        'ensure' => 'directory',
        'owner'  => p[:user],
        'group'  => p[:group],
      })
      should contain_file("#{p[:install_root]}/log").with({
        'ensure' => 'directory',
        'owner'  => p[:user],
        'group'  => p[:group],
      })
      should contain_file('/var/log/selenium').with({
        'ensure' => 'link',
        'owner'  => 'root',
        'group'  => 'root',
        'target' => "#{p[:install_root]}/log",
      })
      should contain_wget__fetch('selenium-server-standalone').with({
        'source'      => "https://selenium.googlecode.com/files/selenium-server-standalone-#{p[:version]}.jar",
        'destination' => "#{p[:install_root]}/jars/selenium-server-standalone-#{p[:version]}.jar",
        'timeout'     => '90',
        'execuser'    => p[:user],
      })
      should contain_logrotate__rule('selenium').with({
        :path          => "#{p[:install_root]}/log",
        :rotate_every  => 'weekly',
        :missingok     => true,
        :rotate        => 4,
        :compress      => true,
        :delaycompress => true,
        :copytruncate  => true,
        :minsize       => '100k',
      })
    end
  end

  context 'for osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}

    context 'no params' do
      it_behaves_like 'selenium', {}
    end

    context 'user => foo' do
      p = { :user => 'foo' }
      let(:params) { p }

      it_behaves_like 'selenium', p
    end

    context 'user => []' do
      p = { :user => [] }
      let(:params) { p }

      it 'should fail' do
        expect {
          should contain_class('selenium')
        }.to raise_error
      end
    end

    context 'group => foo' do
      p = { :group => 'foo' }
      let(:params) { p }

      it_behaves_like 'selenium', p
    end

    context 'group => []' do
      p = { :group => [] }
      let(:params) { p }

      it 'should fail' do
        expect {
          should contain_class('selenium')
        }.to raise_error
      end
    end

    context 'install_root => /foo/selenium' do
      p = { :install_root => '/foo/selenium' }
      let(:params) { p }

      it_behaves_like 'selenium', p
    end

    context 'install_root => []' do
      p = { :install_root => [] }
      let(:params) { p }

      it 'should fail' do
        expect {
          should contain_class('selenium')
        }.to raise_error
      end
    end

    context 'java => /opt/java' do
      p = { :java => '/opt/java' }
      let(:params) { p }

      it_behaves_like 'selenium', p
    end

    context 'java => []' do
      p = { :java => [] }
      let(:params) { p }

      it 'should fail' do
        expect {
          should contain_class('selenium')
        }.to raise_error
      end
    end
  end

end
