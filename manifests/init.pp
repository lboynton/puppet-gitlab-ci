# Install gitlab-ci
class gitlab_ci {
    if $::osfamily == 'RedHat' and $::operatingsystem != 'Fedora' {
        include epel
    }

    include gitlab_ci::db
    include gitlab_ci::redis
    include rvm

    rvm_system_ruby { 'ruby-1.9.3':
        ensure      => 'present',
        default_use => true,
    }

    rvm_gem { 'ruby-1.9.3/bundler': 
        ensure      => present,
        require     => Rvm_system_ruby['ruby-1.9.3'],
    }

    user { 'gitlab_ci':
        ensure      => present,
        comment     => 'GitLab CI',
        system      => true,
        managehome  => true,
    }

    vcsrepo { 'gitlab-ci':
        ensure      => latest,
        path        => '/home/gitlab_ci/gitlab-ci',
        provider    => git,
        source      => 'https://github.com/gitlabhq/gitlab-ci.git',
        revision    => '2-0-stable',
        owner       => 'gitlab_ci',
        group       => 'gitlab_ci',
        require     => User['gitlab_ci'],
    }

    # TODO: Remove hardcoded path, as this will break when ruby version changes
    exec { '/usr/local/rvm/gems/ruby-1.9.3-p374@global/bin/bundle --without development test':
        cwd     => '/home/gitlab_ci/gitlab-ci',
        user    => 'gitlab_ci',
        require => [Rvm_gem['ruby-1.9.3/bundler'], Vcsrepo['gitlab-ci']],
    }
}